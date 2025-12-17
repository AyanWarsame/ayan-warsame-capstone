# Local Access Setup Guide

## Problem
You're getting `DNS_PROBE_FINISHED_NXDOMAIN` because `ayan-warsame.capstone.company.com` doesn't exist in public DNS. You need to add it to your **local machine's** hosts file.

## Solution: Add to Your Local Machine's Hosts File

### For Linux/Mac Users

1. Open terminal on your **local machine** (not the server)

2. Get the ELB IP address:
   ```bash
   nslookup a34fc6306ef174b7da4448774a97fe5a-c127de64f9bef2fd.elb.eu-west-1.amazonaws.com
   ```
   Or use one of these IPs: `52.30.202.78`, `34.249.191.116`, or `54.194.179.140`

3. Edit `/etc/hosts`:
   ```bash
   sudo nano /etc/hosts
   # or
   sudo vim /etc/hosts
   ```

4. Add this line:
   ```
   52.30.202.78 ayan-warsame.capstone.company.com
   ```

5. Save and exit (Ctrl+X, then Y, then Enter for nano)

6. Test:
   ```bash
   curl http://ayan-warsame.capstone.company.com/health
   ```

7. Open in browser: `http://ayan-warsame.capstone.company.com`

### For Windows Users

1. Open Notepad **as Administrator**:
   - Press `Windows Key`
   - Type "Notepad"
   - Right-click and select "Run as administrator"

2. Open the hosts file:
   - File → Open
   - Navigate to: `C:\Windows\System32\drivers\etc\`
   - Change file type to "All Files (*.*)"
   - Open `hosts`

3. Add this line at the end:
   ```
   52.30.202.78 ayan-warsame.capstone.company.com
   ```

4. Save the file

5. Flush DNS cache:
   ```cmd
   ipconfig /flushdns
   ```

6. Open in browser: `http://ayan-warsame.capstone.company.com`

## Alternative: Use Browser Extension

If you can't edit hosts file, use a browser extension:

### Chrome/Edge: ModHeader Extension

1. Install [ModHeader](https://chrome.google.com/webstore/detail/modheader/idgpnmonknjnojddfkpgkljpfnnfcklj)

2. Click the extension icon

3. Add Request Header:
   - Name: `Host`
   - Value: `ayan-warsame.capstone.company.com`

4. Access: `http://a34fc6306ef174b7da4448774a97fe5a-c127de64f9bef2fd.elb.eu-west-1.amazonaws.com`

### Firefox: Modify Headers Extension

1. Install [Modify Headers](https://addons.mozilla.org/en-US/firefox/addon/modify-headers/)

2. Add header: `Host: ayan-warsame.capstone.company.com`

3. Access the ELB URL

## Quick Test

After adding to hosts file, test with:

```bash
# Should return your frontend health
curl http://ayan-warsame.capstone.company.com/health

# Expected: {"status":"healthy","service":"frontend"}
```

## ELB Information

- **ELB Hostname**: `a34fc6306ef174b7da4448774a97fe5a-c127de64f9bef2fd.elb.eu-west-1.amazonaws.com`
- **ELB IPs**: 
  - `52.30.202.78`
  - `34.249.191.116`
  - `54.194.179.140`
- **Your Hostname**: `ayan-warsame.capstone.company.com`
- **Port**: `80` (HTTP)

## Troubleshooting

### Still seeing Ian's app?

1. Clear browser cache: `Ctrl+Shift+Delete` (or `Cmd+Shift+Delete` on Mac)
2. Try incognito/private window
3. Verify hosts file entry is correct
4. Check if you're using the right IP (ELB IPs can change)

### Hosts file not working?

1. Make sure there are no typos
2. Restart browser completely
3. Try `ping ayan-warsame.capstone.company.com` - should resolve to the ELB IP
4. On Windows: Run `ipconfig /flushdns` after editing hosts file

### Need to update ELB IP?

If ELB IP changes, update your hosts file with the new IP:

```bash
# Get current IP
nslookup a34fc6306ef174b7da4448774a97fe5a-c127de64f9bef2fd.elb.eu-west-1.amazonaws.com

# Update /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
```

