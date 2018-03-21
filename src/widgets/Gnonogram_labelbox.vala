/* Holds all row or column clues for gnonograms
 * Copyright (C) 2010 - 2017  Jeremy Wootten
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
/** Widget to hold variable number of clues, with either vertical or horizontal orientation **/
public class LabelBox : Gtk.Grid {
/** PUBLIC **/
    public Gtk.PositionType attach_position {get; construct;}
    public bool vertical_labels  {get; construct;} /* True if contains column labels */

    public Dimensions dimensions {
        set {
            if (value != _dimensions) {
                _dimensions = value;
                resize (value);
            }
        }

        private get {
            return _dimensions;
        }
    }

    public double fontheight {
        set {
            var fh = value.clamp (Gnonograms.MINFONTSIZE, Gnonograms.MAXFONTSIZE);
            if (fh != _fontheight) {
                for (uint index = 0; index < size; index++) {
                    labels[index].fontheight = fh;
                }

                _fontheight = fh;
            }

            if (vertical_labels) {
                min_width = (int)(_dimensions.cols () * 2 * fh);
                min_height = (int)((_dimensions.rows () * 0.5 + 2) * fh);
            } else {
                min_width = (int)((_dimensions.cols () * 0.5 + 1) * fh);
                min_height = (int)(_dimensions.rows () * 2 * fh);
            }
        }
    }

    public LabelBox (Gtk.Orientation orientation) {
        Object (column_homogeneous: true,
                row_homogeneous: true,
                column_spacing: 0,
                row_spacing: 0,
                vertical_labels: (orientation == Gtk.Orientation.HORIZONTAL),
                attach_position: (orientation == Gtk.Orientation.HORIZONTAL) ? Gtk.PositionType.RIGHT : Gtk.PositionType.BOTTOM
                );
    }

    construct {
        labels = new Clue[MAXSIZE];
        size = 0;
    }

    public void highlight (uint index, bool is_highlight) {
        if (index >= size) {
            return;
        }

        labels[index].highlight (is_highlight);
    }

    public void unhighlight_all () {
        for (uint index = 0; index < size; index++) {
            labels[index].highlight (false);
        }
    }

    public void update_label_text (uint index, string? txt) {
        if (txt == null) {
            txt = BLANKLABELTEXT;
        }

        Clue? label = labels[index];
        if (label != null) {
            label.clue = txt;
        }
    }

    public void update_label_complete (uint index, Gee.ArrayList<Block?> grid_blocks) {

        Clue? label = labels[index];
        if (label != null) {
//~ warning ("LBOX update label complete size %i", grid_blocks.size);
            label.update_complete (grid_blocks);
        }
    }

/** PRIVATE **/
    /* Backing variables - do not assign directly */
    private Dimensions _dimensions;
    private double _fontheight;
    private int min_width = -1;
    private int min_height = -1;
    /* ----------------------------------------- */

    private Clue[] labels;
    private int size;
    private int other_size; /* Size of other label box */

    private Clue new_label (bool vertical) {
        var label = new Clue (vertical);
        label.size = (int)(vertical_labels ? dimensions.height : dimensions.width);
        label.fontheight = _fontheight;
        label.show_all ();

        return label;
    }

    private void resize (Dimensions dimensions) {
        assert (size >= 0);
        unhighlight_all();

        var new_size = (int)(vertical_labels ? dimensions.width : dimensions.height);
        var new_other_size = (int)(vertical_labels ? dimensions.height : dimensions.width);

        while (size < new_size) {
            var label = new_label (vertical_labels);
            if (size > 0) {
                var last_label = labels[size - 1];
                attach_next_to (label, last_label, attach_position, 1, 1);
            } else {
                attach (label, 0, 0, 1, 1);
            }

            labels[size] = label;
            size++;
        }

        while (size > new_size) {
            if (vertical_labels) {
                remove_column (size - 1);
            } else {
                remove_row (size - 1);
            }
            /* No need to destroy unused labels */
            size--;
        }

        size = new_size;
        other_size = new_other_size;

        for (uint index = 0; index < size; index++) {
            labels[index].size = other_size;
        }

        for (uint index = 0; index < size; index++) {
            labels[index].clue = ("0");
        }
    }

    public override void get_preferred_width (out int _min_width, out int _nat_width) {
        _min_width = min_width;
        _nat_width = min_width;
    }

    public override void get_preferred_height (out int _min_height, out int _nat_height) {
        _min_height = min_height;
        _nat_height = min_height;
    }
}
}
