
/* Entry point for gnonograms  - initializes application and launches game
 * Copyright (C) 2010-2017  Jeremy Wootten
 *
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Author:
 *  Jeremy Wootten <jeremywootten@gmail.com>
 */

namespace Gnonograms {
    public const Cell NULL_CELL = { uint.MAX, uint.MAX, CellState.UNDEFINED };
    public static int MAXSIZE = 50; // max number rows or columns
    public static int MINSIZE = 5; // Change to 1 when debugging
    public static double MINFONTSIZE = 8.0;
    public static double MAXFONTSIZE = 36.0;
    public static int FAILED_PASSES = 0;

    public static double FONT_ASPECT_RATIO = 1.2;
    public static int HEADER_HEIGHT = Gtk.IconSize.LARGE_TOOLBAR;
    public static int GRID_BORDER = 6;
    public static int GRID_COLUMN_SPACING = 6;
    public static double TYPICAL_MAX_BLOCKS_RATIO = 0.3;
    public static double USABLE_MONITOR_HEIGHT = 0.85;
    public static double USABLE_MONITOR_WIDTH = 0.95;

    public const string BLOCKSEPARATOR = ", ";
    public const string BLANKLABELTEXT = N_("?");
    public const string GAMEFILEEXTENSION = ".gno";
    public const string UNSAVED_FILENAME = "Unsaved Game" + GAMEFILEEXTENSION;
    public const int MAX_TRIES_PER_GRADE = 1000;
    public const string UNTITLED_NAME = N_("Untitled");

    public const string APP_ID = "com.github.jeremypw.gnonograms";
    public const string APP_NAME = "Gnonograms";

    public const string SETTING_FILLED_COLOR = "#000000"; /* Elementary Black 900 */
    public const string SETTING_EMPTY_COLOR = "#fafafa"; /* Elementary Silver 100 */
    public const string SOLVING_FILLED_COLOR = "#180297"; /* Gnonograms Dark Purple */
    public const string SOLVING_EMPTY_COLOR = "#ffff00";  /* Pure Yellow */
    public const string UNKNOWN_COLOR = "#d4d4d4"; /* Elementary Silver 300 */
    public const string GRID_COLOR = "#000000"; /* Elementary Black 900 */

    public const string DARK_TEXT       = "#000000"; /* Elementary Black 900 */
    public const string PALE_TEXT       = "#fafafa"; /* Elementary Silver 100 */
    public const string DARK_BACKGROUND = "#180297"; /* Gnonograms Dark Purple */
    public const string PALE_BACKGROUND = "#cdc9e0"; /* Gnonograms Pale Purple */
    public const string DARK_SHADOW     = "#1a1a1a"; /* Elementary Black 700 */
    public const string PALE_SHADOW     = "#fafafa"; /* Elementary Silver 100 */

}
