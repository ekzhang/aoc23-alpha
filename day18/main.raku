# Raku is Perl 6. I've never written much Perl code, but my impression is that
# as a dynamic language, it tends to play very fast and loose with syntax. But
# for this problem it's more than adequate enough!
#
# I'm surprised that I can basically index any non-array object with [0], and it
# will act as the identity. Also surprised by the variable syntax.
#
# There's some really wacky thing about "braids" and sub-languages within Raku
# related to the "HOW" metaprogramming structure. I don't know enough to comment
# on that part. Maybe it's kind of like Ruby's eigenclass hierarchy?

# Takes an array of two-element lists (dir, len).
sub calculate_volume(@pairs) {
    my $y = 0;
    my $perimeter = 0;
    my $area = 0;

    for @pairs -> ($dir, $len) {
        $perimeter += $len;
        given $dir {
            when 'U' { $y += $len }
            when 'D' { $y -= $len }
            when 'L' { $area -= $len * $y }
            when 'R' { $area += $len * $y }
        }
    }

    # Use Pick's theorem again!
    # Total number of squares is: |area| + perimeter/2 + 1
    return abs($area) + $perimeter/2 + 1;
}

my @part1 = ();
my @part2 = ();

for $*IN.lines -> $line {
    my ($dir, $len, $color) = $line.split(/\s+/);
    $len = +$len;
    @part1.push(($dir, $len));

    my $dir2 = 'RDLU'.substr(+$color.substr(7, 1), 1);
    my $len2 = :16($color.substr(2, 5));
    @part2.push(($dir2, $len2));
}

say calculate_volume(@part1);
say calculate_volume(@part2);
