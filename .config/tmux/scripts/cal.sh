#!/bin/bash

ALERT_IF_IN_NEXT_MINUTES=10
ALERT_POPUP_BEFORE_SECONDS=10
NERD_FONT_FREE=""
NERD_FONT_MEETING="󰤙"
MAX_TITLE_LEN=21

get_attendees() {
	attendees=$(
	icalBuddy \
		--includeCals "Metalab,Personal" \
		--includeEventProps "attendees" \
		--propertyOrder "datetime,title" \
		--noCalendarNames \
		--dateFormat "%A" \
		--includeOnlyEventsFromNowOn \
		--limitItems 1 \
		--excludeAllDayEvents \
		--separateByDate \
		--excludeEndDates \
		--bullet "" \
		eventsToday)
}

parse_attendees() {
	attendees_array=()
	for line in $attendees; do
		attendees_array+=("$line")
	done
	number_of_attendees=$((${#attendees_array[@]}-3))
}

get_next_meeting() {
	next_meeting=$(icalBuddy \
		--includeCals "Metalab,Personal" \
		--includeEventProps "title,datetime" \
		--propertyOrder "datetime,title" \
		--noCalendarNames \
		--dateFormat "%A" \
		--includeOnlyEventsFromNowOn \
		--limitItems 1 \
		--excludeAllDayEvents \
		--separateByDate \
		--bullet "" \
		eventsToday)
}

get_next_next_meeting() {
	end_timestamp=$(date +"%Y-%m-%d ${end_time}:01 %z")
	tonight=$(date +"%Y-%m-%d 23:59:00 %z")
	next_next_meeting=$(
	icalBuddy \
		--includeCals "Metalab,Personal" \
		--includeEventProps "title,datetime" \
		--propertyOrder "datetime,title" \
		--noCalendarNames \
		--dateFormat "%A" \
		--limitItems 1 \
		--excludeAllDayEvents \
		--separateByDate \
		--bullet "" \
		eventsFrom:"${end_timestamp}" to:"${tonight}")
}

parse_result() {
	array=()
	for line in $1; do
		array+=("$line")
	done
	time="${array[2]}"
	end_time="${array[4]}"

	# icalBuddy prints the title on the line directly after the time line.
	# Extract it from there (the old array slice dropped leading title words).
	title=""
	if [[ -n "$time" ]]; then
		title=$(printf '%s\n' "$1" | grep -A1 -E "^[[:space:]]*${time}([[:space:]]|$)" | tail -n +2 | head -1 | sed -E 's/^[[:space:]]*//')
	fi
	[[ -z "$title" ]] && title="${array[*]:5:30}"
}

# Determine which calendar the selected meeting belongs to.
# Returns "ML" for Metalab, "P" for Personal (default).
get_source() {
	local times
	times=$(icalBuddy \
		--includeCals "Metalab" \
		--includeEventProps "datetime" \
		--noCalendarNames \
		--includeOnlyEventsFromNowOn \
		--excludeAllDayEvents \
		--excludeEndDates \
		--bullet "" \
		--limitItems 10 \
		eventsToday 2>/dev/null | grep -oE '[0-9]{1,2}:[0-9]{2}')
	if printf '%s\n' "$times" | grep -qx "$1"; then
		echo "ML"
	else
		echo "P"
	fi
}

# Clean up a meeting title for the status bar:
#   - drop text inside ( ), [ ], < > (usually just context) and the brackets
#   - drop emoji / pictographic symbols (accents are kept)
#   - collapse whitespace, then trim to MAX_TITLE_LEN chars + ellipsis
sanitize_title() {
	printf '%s' "$1" | MAXLEN="$MAX_TITLE_LEN" perl -CSD -ne '
		chomp;
		s/\([^)]*\)//g; s/\[[^\]]*\]//g; s/<[^>]*>//g;
		s/[\x{1F000}-\x{1FAFF}\x{2190}-\x{21FF}\x{2300}-\x{27BF}\x{2B00}-\x{2BFF}\x{FE00}-\x{FE0F}\x{1F1E6}-\x{1F1FF}]//g;
		s/[][(){}<>]//g;
		s/\s+/ /g; s/^\s+//; s/\s+$//;
		my $m = $ENV{MAXLEN};
		print length() > $m ? substr($_, 0, $m) . "\x{2026}" : $_;
	'
}

calculate_times(){
	if [[ -z "$time" ]]; then
		minutes_till_meeting=9999
		minutes_till_end=9999
		return
	fi
	epoc_meeting=$(date -j -f "%H:%M" "$time" +%s 2>/dev/null || date -j -f "%R" "$time" +%s 2>/dev/null)
	epoc_now=$(date +%s)
	epoc_diff=$((epoc_meeting - epoc_now))
	minutes_till_meeting=$((epoc_diff/60))

	# Minutes until the meeting ends, used once it's already underway.
	minutes_till_end=9999
	if [[ -n "$end_time" ]]; then
		epoc_end=$(date -j -f "%H:%M" "$end_time" +%s 2>/dev/null || date -j -f "%R" "$end_time" +%s 2>/dev/null)
		[[ -n "$epoc_end" ]] && minutes_till_end=$(((epoc_end - epoc_now)/60))
	fi
}

display_popup() {
	popup_lock="/tmp/tmux_meeting_popup.lock"

	if [[ ! -f "$popup_lock" ]]; then
		printf -v cmd 'icalBuddy --includeCals "Metalab,Personal" --propertyOrder "datetime,title" --noCalendarNames --formatOutput --includeEventProps "title,datetime,notes,url,attendees" --includeOnlyEventsFromNowOn --limitItems 1 --excludeAllDayEvents eventsToday'

		tmux display-popup \
				-S 'fg=#eba0ac' \
				-w35% \
				-h40% \
				-T 'Meeting Details' \
				-E \
				\"$cmd\"

		touch "$popup_lock"
		(sleep 60 && rm -f "$popup_lock") &
	fi
}

print_tmux_status() {
	if [[ $minutes_till_meeting -lt $ALERT_IF_IN_NEXT_MINUTES \
		&& $minutes_till_meeting -gt -60 ]]; then
		local src clean when
		src=$(get_source "$time")
		clean=$(sanitize_title "$title")
		if [[ $minutes_till_meeting -gt 0 ]]; then
			when="${minutes_till_meeting} minutes"
		elif [[ $minutes_till_end -gt 0 && $minutes_till_end -ne 9999 ]]; then
			when="${minutes_till_end} min left"
		else
			when="now"
		fi
		echo "$NERD_FONT_MEETING [$src] $time $clean ($when)"
	else
		echo "$NERD_FONT_FREE"
	fi

	# if [[ $epoc_diff -gt $ALERT_POPUP_BEFORE_SECONDS && $epoc_diff -lt $ALERT_POPUP_BEFORE_SECONDS+10 ]]; then
		# display_popup
	# fi
}

main() {
	get_attendees
	parse_attendees
	get_next_meeting
	parse_result "$next_meeting"
	calculate_times
	if [[ "$next_meeting" != "" && $number_of_attendees -lt 2 ]]; then
		get_next_next_meeting
		parse_result "$next_next_meeting"
		calculate_times
	fi
	print_tmux_status
}

main
