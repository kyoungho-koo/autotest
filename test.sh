
bench()
{
 echo $1
}

loop()
{
  for i in $*
  do
   $1 $7$i
  done
}


loop $(loop bench 1 2 3 4 5 A) 1 2 3 4 5 B 
