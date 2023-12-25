# Finally, the famously dynamic language Tcl!
#
# Going through https://www.tcl.tk/man/tcl8.5/tutorial/tcltutorial.html, which
# is a classic tutorial. I feel like I'm connecting with ancestors from another
# generation of programmers. Also read some of the Redis testsuite, and a bit of
# writing from antirez: http://antirez.com/articoli/tclmisunderstood.html
#
# The absolute classic thread of "Ousterhout's dichotomy" fame:
# https://groups.google.com/g/comp.lang.tcl/c/7JXGt-Uxqag/m/3JBTj5I43yAJ

proc gcd {p q} {
    # From https://wiki.tcl-lang.org/page/Greatest+common+denominator
    while {$q != 0} {set q [expr {$p % [set p $q]}]}
    set p
}

while 1 {
    set line [gets stdin]
    if {$line eq ""} {
        break
    }
    lassign [split $line -] node dest
    if {$node == "broadcaster "} {
        set node_type broadcaster
        set node broadcaster
    } else {
        set node_type [string index $node 0]
        set node [string range $node 1 end-1]
    }
    set dest [string range $dest 2 end]
    set dest [lmap x [split $dest ,] {string trim $x}]
    lappend nodes $node
    dict set node_types $node $node_type
    dict set edges $node $dest
    if {"rx" in $dest} {
        set pre_rx $node
    }
}

proc advance {state} {
    global nodes node_types edges pre_rx

    # initial button press
    set signals(0) 1
    set signals(1) 0
    set rx_source_list ""

    # state is a dict of the last high/low signal for each node
    lappend frontier {broadcaster 0 ""}

    # initialize separate memory for conjunction cell inputs
    foreach node $nodes {
        foreach dest [dict get $edges $node] {
            if {[dict exists $node_types $dest]} {
                set node_type [dict get $node_types $dest]
                if {$node_type == "&"} {
                    dict set memory $dest $node [dict get $state $node]
                }
            }
        }
    }

    while {[llength $frontier]} {
        set next_frontier {}
        foreach frontier_item $frontier {
            lassign $frontier_item node signal from_node
            set node_type [dict get $node_types $node]
            set output ""
            if {$node_type == "broadcaster"} {
                set output $signal
            } elseif {$node_type == "%"} {
                # Flip-flop cell
                if {!$signal} {
                    set last_output [dict get $state $node]
                    set output [expr {!$last_output}]
                }
            } elseif {$node_type == "&"} {
                # Conjunction cells are like NAND gates with memory
                dict set memory $node $from_node $signal
                set all_high 1
                foreach prev_input [dict values [dict get $memory $node]] {
                    if {!$prev_input} {
                        set all_high 0
                        break
                    }
                }
                set output [expr {!$all_high}]
            } else {
                # print unknown node type and exit with error
                puts "unknown node type $node_type"
                exit 1
            }

            if {$output != ""} {
                dict set state $node $output
                foreach dest [dict get $edges $node] {
                    incr signals($output)
                    if {$dest == $pre_rx && $output} {
                        lappend rx_source_list $node
                    }
                    if {[dict exists $node_types $dest]} {
                        lappend next_frontier [list $dest $output $node]
                    }
                }
            }
        }
        set frontier $next_frontier
    }

    return [list $signals(0) $signals(1) $rx_source_list $state]
}

# puts "nodes: $nodes"
# puts "node_types: $node_types"
# puts "edges: $edges"

foreach node $nodes {
    dict set initial_state $node 0
}

# Part 1
# Advance 1000 times and output the total number of low * high signals.
set state $initial_state
set low_signals 0
set high_signals 0
for {set i 0} {$i < 1000} {incr i} {
    lassign [advance $state] signals(0) signals(1) _ state
    incr low_signals $signals(0)
    incr high_signals $signals(1)
}
puts [expr {$low_signals * $high_signals}]

# Part 2
# Fewest number of button presses to deliver a low signal to rx. Take the LCM of
# the first step each node delivers a high signal to the conjunction.
foreach node $nodes {
    if {$pre_rx in [dict get $edges $node]} {
        dict set periods $node 0
    }
}
set state $initial_state
for {set i 0} 1 {incr i} {
    lassign [advance $state] _ _ rx_source_list state
    foreach node $rx_source_list {
        if {![dict get $periods $node]} {
            dict set periods $node [expr {$i + 1}]
        }
    }
    if {0 ni [dict values $periods]} {
        break
    }
}
set ans 1
foreach period [dict values $periods] {
    set ans [expr {$ans * $period / [gcd $ans $period]}]
}
puts $ans
