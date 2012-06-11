#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Math::Prime::Util qw/prime_count prime_count_lower prime_count_upper prime_count_approx/;

my $use64 = Math::Prime::Util::_maxbits > 32;
my $extra = defined $ENV{RELEASE_TESTING} && $ENV{RELEASE_TESTING};

plan tests => 14*3 + 8 + 6*$extra + 2*18*$use64 + 12 + 5*$use64;

#  Powers of 2:  http://oeis.org/A007053/b007053.txt
#  Powers of 10: http://oeis.org/A006880/b006880.txt
my %pivals32 = (
                   1 => 0,
                  10 => 4,
                 100 => 25,
                1000 => 168,
               10000 => 1229,
              100000 => 9592,
             1000000 => 78498,
            10000000 => 664579,
           100000000 => 5761455,
          1000000000 => 50847534,
               65535 => 6542,
            16777215 => 1077871,
          2147483647 => 105097565,
          4294967295 => 203280221,
);
my %pivals64 = (
         10000000000 => 455052511,
        100000000000 => 4118054813,
       1000000000000 => 37607912018,
      10000000000000 => 346065536839,
     100000000000000 => 3204941750802,
    1000000000000000 => 29844570422669,
   10000000000000000 => 279238341033925,
  100000000000000000 => 2623557157654233,
 1000000000000000000 => 24739954287740860,
10000000000000000000 => 234057667276344607,
         68719476735 => 2874398515,
       1099511627775 => 41203088796,
      17592186044415 => 597116381732,
     281474976710655 => 8731188863470,
    4503599627370495 => 128625503610475,
   72057594037927935 => 1906879381028850,
 1152921504606846975 => 28423094496953330,
18446744073709551615 => 425656284035217743,
);
while (my($n, $pin) = each (%pivals32)) {
  cmp_ok( prime_count_upper($n), '>=', $pin, "Pi($n) <= upper estimate" );
  cmp_ok( prime_count_lower($n), '<=', $pin, "Pi($n) >= lower estimate" );
  if ( ($n <= 2000000) || $extra ) {
    is( prime_count($n), $pin, "Pi($n) = $pin" );
  }
  my $approx_range = abs($pin - prime_count_approx($n));
  my $range_limit = ($n <= 1000000000) ? 1100 : 70000;
  cmp_ok( $approx_range, '<=', $range_limit, "prime_count_approx($n) within $range_limit");
}
if ($use64) {
  while (my($n, $pin) = each (%pivals64)) {
    cmp_ok( prime_count_upper($n), '>=', $pin, "Pi($n) <= upper estimate" );
    cmp_ok( prime_count_lower($n), '<=', $pin, "Pi($n) >= lower estimate" );
  }
}

#  ./primesieve 1e10 -o2**32 -c1
#  ./primesieve 24689 7973249 -c1
my %intervals = (
  "868396 to 9478505" => 563275,
  "1118105 to 9961674" => 575195,
  "24689 to 7973249" => 535368,
  "1e10 +2**16" => 2821,
  "17 to 13"    => 0,
  "3 to 17"     => 6,
  "4 to 17"     => 5,
  "4 to 16"     => 4,
  "191912783 +248" => 2,
  "191912784 +247" => 1,
  "191912783 +247" => 1,
  "191912784 +246" => 0,

  "1e14 +2**16" => 1973,
  "127976334671 +468" => 2,
  "127976334672 +467" => 1,
  "127976334671 +467" => 1,
  "127976334672 +466" => 0,
);

while (my($range, $expect) = each (%intervals)) {
  my($low,$high);
  if ($range =~ /(\S+)\s+to\s+(\S+)/) {
    $low = fixnum($1);
    $high = fixnum($2);
  } elsif ($range =~ /(\S+)\s*\+\s*(\S+)/) {
    $low = fixnum($1);
    $high = $low + fixnum($2);
  } else {
    die "Can't parse test data";
  }
  next if $high > ~0;
  is( prime_count($low,$high), $expect, "prime_count($range) = $expect");
}

sub fixnum {
  my $nstr = shift;
  $nstr =~ s/^(\d+)e(\d+)$/$1*(10**$2)/e;
  $nstr =~ s/^(\d+)\*\*(\d+)$/$1**$2/e;
  die "Unknown string in test" unless $nstr =~ /^\d+$/;
  $nstr;
}
 
# TODO: intervals.  From primesieve:
#    155428406, // prime count 2^32 interval starting at 10^12
#    143482916, // prime count 2^32 interval starting at 10^13
#    133235063, // prime count 2^32 interval starting at 10^14
#    124350420, // prime count 2^32 interval starting at 10^15
#    116578809, // prime count 2^32 interval starting at 10^16
#    109726486, // prime count 2^32 interval starting at 10^17
#    103626726, // prime count 2^32 interval starting at 10^18
#    98169972}; // prime count 2^32 interval starting at 10^19


