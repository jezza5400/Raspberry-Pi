# Samba File Sharing

## Setup

Open the Raspberry Pi terminal

Enter this command to fully update your raspberry pi:

```bash
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean
```

Enter this command to install Samba and Samba Common Bin:

```bash
sudo apt install -y samba samba-common-bin
```

Next we need to set a folder to share. To do so enter this command:

```bash
sudo nano /etc/samba/smb.conf
```

Navigate to the bottom of this file and add these lines (Make sure you change the YourPiUsername to you Raspberry Pi's username);

```conf
[Shared-Pi]
path=/home/<YourPiUsername>
writeable=Yes
create mask=0777
directory mask=0777
public=no
```

You will also need to edit the line under [homes] `read only = yes` to `read only = no` and `browseable = no` to `browseable = yes`
Press `ctrl+x` then when prompted `y` then press `enter`
Now we need to add a samba password. to do so enter this command:

```bash
sudo smbpasswd -a <YourPiUsername>
```

(Again make sure you change the YourPiUsername to you Raspberry Pi's username)

When prompted enter your desired password (Note the password you enter will not show up on the screen but is still being entered)
Then restart smb using this command:

```bash
sudo systemctl restart smbd
```

## Connecting

First we need to find the ip address of our pi using this command: `hostname -I` make note of the first output
Now back in your windows pc navigate to the this pc folder and then right click and press `Add a network location`
Then `Next` then `Choose a custom network location` and `Next`
Next enter your raspberry pi's ip address after two backslashes with the folder you shared eg.

```plaintext
\\192.168.1.219\Shared-Pi
```

Now you Pi should appear in the this pc menu on your windows device
