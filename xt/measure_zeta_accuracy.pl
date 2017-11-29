#!/usr/bin/env perl
use warnings;
use strict;
use Math::BigInt lib=>'GMP';
use Math::BigFloat lib=>'GMP';
use Math::Prime::Util qw/:all/;
use Term::ANSIColor;

my $acc = shift || 40;
die "Max accuracy for this test = 130 digits\n" if $acc > 130;

# gp
# \p 200
# zeta( ... )

my %rvals = (
  '1.1' => '9.584448464950809826386400791735523039948452821749956287341996814480303837459322691616078413409515648694639395119228819064344703916091772977408730498635107285330892384233095746851896144943768106376250',
  '1.5' => '1.6123753486854883433485675679240716305708006524000634075733282488149277676882728609962438681263119523829763587721497556981576329684344591344383205618083360083393339628054805416629485268482979816864585',
  '2' => '0.6449340668482264364724151666460251892189499012067984377355582293700074704032008738336289006197587053040043189623371906796287246870050077879351029463308662768317333093677626050952510068721400547968116',
  '10.6' => '0.0006535124140849160091501143426339766925221571365653473384612636596703480872941784752196831016776418120994086666918881480106625093513591339409876063582144423806112461223442629387528335045020747185807',
  '40' => '0.0000000000009094947840263889282533118386949087538600009908788285054797101120253686956071035306072205287331384902727431401990215047047204991063494101565431604021268515739713441458101750970056651490623',
  '40.5' => '0.0000000000006431099185658679387082225425519898498591882791889454081987607830570099179633851971961276745357473820567338532744684721389592539881397336120645131348781330604831257993490233960843733407184',
  '80' => '0.0000000000000000000000008271806125530344403671105616744072404009681112297828911634240702948673833268263801251794903859145412800678073752551076032591373513167395826219721614628514247211772783817197087',
  '200' => '0.0000000000000000000000000000000000000000000000000000000000006223015277861141707144064053780124278238871664711431331935339387492776093057166188727575094880097645495454472391197851568776550275806071517',
);

my $acctext = ($acc == 40) ? "default 40-digit" : "$acc-digit";
print <<EOT;
Using $acctext accuracy.

The first number is the precalculated correct value.
The second number is the answer RiemannZeta is giving.
Differences are highlighted in red.

To prevent differences for accuracy > 38 digits you need one of:
 - a recent Math::Prime::Util::GMP backend (late 2016)
 - a recent Math::BigInt                   (mid-2014)
EOT


foreach my $vstr (sort { $a <=> $b } keys %rvals) {
  my $zeta_str = $rvals{$vstr};
  my $lead = index($zeta_str, '.');
  my $v    = Math::BigFloat->new($vstr);
  my $zeta = Math::BigFloat->new($rvals{$vstr});
  $v->accuracy($acc) if $acc != 40;
  #print "zeta($v) = $zeta\n";
  my $mpuzeta = RiemannZeta($v);
  my $mpuzeta_str = ref($mpuzeta) eq 'Math::BigFloat'
                    ? $mpuzeta->bstr
                    : sprintf("%.69Lf", $mpuzeta);
  my $mzlen = length($mpuzeta_str);
  # Truncate zeta_str to length of mpuzeta_str, with rounding.
  {
    $zeta_str = Math::BigFloat->new($zeta_str)->bmul(1,$acc)->bstr;
  }
  if ($zeta_str ne $mpuzeta_str) {
    my $n = 0;
    $n++ while substr($zeta_str, $n, 1) eq substr($mpuzeta_str, $n, 1);
    $mpuzeta_str = substr($mpuzeta_str, 0, $n)
                   . colored(substr($mpuzeta_str, $n), "red");
  }
  printf "%5.1f %s\n", $v, $zeta_str;
  printf "      %s\n", $mpuzeta_str;
  print "\n";
}
