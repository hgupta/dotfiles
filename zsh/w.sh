for i in *
do
  read -p "Move $i? [y/n] -> " yn
  if [ "$yn" = "y" ]; then
    mv $i "__$i"
  fi
  echo ""
done
