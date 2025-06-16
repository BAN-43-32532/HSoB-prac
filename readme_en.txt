HSoBprac by BAN_43_32532
Special thanks to bilibili@qwerbmb and his "真珠岛练习器 v1.2" (https://b23.tv/BV15yDZYdEkd)

==================================================

Usage:
Move the "dnh" folder into the game dir "th_hsob_112".
Overwrite collision files (should only be one file "th_dnh.def").

Note:
If the game uses Chinese patch, the game title may
appear garbled (this won’t affect gameplay).
You may also choose not to overwrite "th_dnh.def",
and instead open the original file at th_hsob_112/dnh/th_dnh.def,
then manually add the following line at the end of the file:
package.script.main = prac/Main.dnh

==================================================

To disable HSoBprac:
No need to delete the added code — just comment out the last line:
package.script.main = prac/Main.dnh
by adding two slashes // in front:
//package.script.main = prac/Main.dnh
To re-enable it, simply remove the slashes.

Note:
All HSoBprac code is inside the dnh/prac folder.
To completely remove the tool, just delete this folder,
and remove the last line in th_dnh.def:
package.script.main = prac/Main.dnh

==================================================

Features:
1. All features from “真珠岛练习器 v1.2”
2. Additional practice support for stage Extra
3. More granular stage section practice
4. Advanced features (compatible with replay; will leave marks in replays):
 - Invincibility
 - Real-time editing of score, resources, point value, graze count, etc.
 - Hitbox display ...