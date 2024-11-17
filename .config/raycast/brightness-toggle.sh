# get main display
result=$(brightness -l | grep -Eo "display 1:.*ID 0x[0-9a-f]+|display 1: brightness [0-9.]+")
id=$(echo "$result" | grep -Eo "ID 0x[0-9a-f]+" | cut -d'x' -f2)
brightness=$(echo "$result" | grep -Eo "brightness [0-9.]+" | awk '{print $2}')

if [[ "$(echo "$brightness == 0" | bc -l)" -eq 1 ]]; then
  brightness -d $id 0.8
else
  brightness -d $id 0 
fi

