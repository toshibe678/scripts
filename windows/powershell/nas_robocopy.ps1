# taskschd.msc でタスクスケジューラを開いて起動後に実行するように設定

# ドライブをマウント
# $SecureString = ConvertTo-SecureString "ロック解除パスワード" -AsPlainText -Force
# Unlock-BitLocker -MountPoint "E:" -Password $SecureString

# robocopy実行
robocopy Y:\ E:\ /LOG:C:\Users\toshi\robocopy-Log.log /MIR /DCOPY:DT /COPY:DT /FFT /TEE /NP /XJF /XJD /MT:128 /COMPRESS /R:0 /W:0 /XD "System Volume Information" "$RECYCLE.BIN"
