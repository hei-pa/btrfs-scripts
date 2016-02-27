# btrfs-scripts

Script collection to create incement backups on btrfs filesystem with systemd.

## Install

1. Move backup.service and backup.timer to systemd (e.g. /etc/systemd/system or /usr/lib/systemd/system)
2. Change the UUID in backup.service to match your source BTRFS device and your destination BTRFS device
3. Change the last param in backup.service ExecStart to match your BTRFS subvolume
4. Move backup.sh to /usr/loca/bin/ and make it executable `chmod +x /usr/local/bin/backup.sh`
5. Execute `systemctl daemon-reload`
6. Execute `systemctl start backup.service` for a initial test and verify everything looks like expected
  * If not have a look to `systemctl status backup.service`
7. Change the backup.timer OnCalendar property to your needs
8. Execute `systemctl start backup.timer` and `systemctl enable backup.timer` to enable it permanent

You are done :)

