# 空きメモリが知りたい
MEMORY_CHECK=`free`

# ディスクの空き容量が知りたい
DISK_CHECK=`df -h`

# iノードの使用率が知りたい
INODE_CHECK=`df -i`

# /のディレクトリ以下のディスクの使用量を知りたい
ROOT_DISK_CHECK=`du -h --max-depth=1 /`

# 物理ディスクの空き容量が知りたい(LVMを使っている場合)
PV_CHECK=`pvdisplay`

# LISTENしているポート一覧を知りたい。
LISTEN_PORT_CHECK=`netstat -tunlp`

# 特定のポートを使用しているプロセスが知りたい
PORT_PROCESS_CHECK=`lsof -i:80`

# 特定のファイルを開いているプロセスが知りたい
FILE_PROCESS_CHECK=`lsof /etc/passwd`

# プロセスが掴んでいるファイル一覧が知りたい
PROCESS_FILE_CHECK=`lsof -p 1`

# プロセス内のスレッドの数を確認したい
THREAD_CHECK=`ps -eLf`

# 稼動しているプロセスを検索したい。
PROCESS_CHECK=`pgrep -l syslog`

# プロセスのメモリマップを確認したい
PROCESS_MAP_CHECK=`pmap 1`

# ディスクI/O使用率を定期的に取得したい。
DISK_IO_CHECK=`vmstat -d 5`