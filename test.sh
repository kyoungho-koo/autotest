CHECK=$(echo sh | grep busy)

echo $CHECK
if [ "$CHECK" = "" ]; then
  echo "haha"
else
  echo "dd"
fi;
