#!/usr/bin/awk -f

/POSCAR:/ {
  # read number of species and atoms (per species)
  ntyp = (NF-1) / 2
  ntot = 0

  for (i=0; i<ntyp; i++) {
    typ[i] = $(2*i+2)
    nat[i] = $(2*i+3)
    ntot += nat[i]
  }
  print "CRYSTAL"
}
/^\s*direct lattice vectors/ {
  # read lattice vectors and store in lat in "TV: (a 0 0) (0 b 0) (0 0 c)" form
  for (i=0; i<3; i++) {
    getline
    lat[i] = sprintf("    %.6f %.6f %.6f", $1, $2, $3)
  }
}
/POSITION/ {
  frame++
  # print out header
  print "PRIMVEC", frame
  for (i=0; i<3; i++) {
    print lat[i]
  }

  print "PRIMCOORD", frame
  print ntot, "1"

  getline

  # read and print out atoms
  icur = 0
  cur = nat[0]

  for (i=0; i<ntot; i++) {
    getline

    if ( i == cur ) {
      icur++
      cur  += nat[icur]
    }

    printf "%-2s %14.10f %14.10f %14.10f\n", typ[icur], $1, $2, $3
  }
}
