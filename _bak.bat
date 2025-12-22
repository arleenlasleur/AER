cd..
if exist AER.7z.old del AER.7z.old
ren AER.7z AER.7z.old
7za a -mx9 -bb0 -r AER.7z AER
7za a -mx9 -bb0 -r AER.7z scitools
7za a -mx9 -bb0 -r AER.7z linescomm
copy AER.7z E:\work\freezer\unreal\swa_AER.7z /y
attrib E:\work\freezer\unreal\swa_AER.7z -a
copy AER.7z L:\rebak\wetfiles\unreal\swa_AER.7z /y
attrib L:\rebak\wetfiles\unreal\swa_AER.7z -a
copy AER.7z H:\rebak\wetfiles\unreal\swa_AER.7z /y
attrib L:\rebak\wetfiles\unreal\swa_AER.7z -a
copy AER.7z I:\rebak\wetfiles\unreal\swa_AER.7z /y
attrib L:\rebak\wetfiles\unreal\swa_AER.7z -a
