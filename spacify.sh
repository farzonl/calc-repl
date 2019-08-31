find . -name "*.l" | while read line; do expand -t 4 $line > $line.new; mv $line.new $line; done
find . -name "*.y" | while read line; do expand -t 4 $line > $line.new; mv $line.new $line; done
