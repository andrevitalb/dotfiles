#!/bin/bash
python_version=$(python -V 2>/dev/null | sed 's/Python //')
if [ $? -eq 0 ]; then
    echo "$python_version"
else
    echo "Python not found"
fi
