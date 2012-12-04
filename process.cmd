for /d %%2 in (???.) do (
  cd %%2
  for %%1 in (*.rtf) do unrtf --text "%%1" > "%%1.text"
  ..\proc.rb
  ..\relog.rb
  7z a ..\%%2.7z *.log
  cd ..
  ren %%2 %%2.done
)
stat.rb
