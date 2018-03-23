/* Displays clues for gnonograms
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
 *  Jeremy Wootten <jeremyw@elementaryos.org>
 */

namespace Gnonograms {

class AppMenu : Gtk.MenuButton {
    private const Difficulty MIN_GRADE = Difficulty.EASY; /* TRIVIAL and VERY EASY GRADES not worth supporting */
    private AppPopover app_popover;
    private AppSetting grade_setting;
    private AppSetting row_setting;
    private AppSetting column_setting;
    private AppSetting title_setting;
    private AppSetting strikeout_setting;
    private Gtk.Grid grid;

    public Dimensions dimensions {get; set;}
    public Difficulty grade {get; set;}
    public string title {get; set;}
    public bool strikeout_complete {get; set;}

    construct {
        popover = new AppPopover (this);
        app_popover = (AppPopover)popover;

        grid = new Gtk.Grid ();
        popover.add (grid);

        grade_setting = new GradeChooser ();
        row_setting = new ScaleGrid (_("Rows"), 10, 50, 5);
        column_setting = new ScaleGrid (_("Columns"), 10, 50, 5);
        title_setting = new TitleEntry ();
        strikeout_setting = new SettingSwitch (_("Strike out complete blocks"));

        int pos = 0;
        add_setting (ref pos, grade_setting);
        add_setting (ref pos, row_setting);
        add_setting (ref pos, column_setting);
        add_setting (ref pos, title_setting);
        add_setting (ref pos, strikeout_setting);

        grid.margin = 12;
        grid.row_spacing = 6;
        grid.column_spacing = 6;
        grid.column_homogeneous = false;

        toggled.connect (() => { /* Allow parent to set values first */
            if (active) {
                update_dimension_settings ();
                update_grade_setting ();
                update_title_setting ();
                update_strikeout_setting ();
                popover.show_all ();
            }
        });

        app_popover.apply_settings.connect (() => {
            update_properties ();
        });

        notify["dimensions"].connect (() => {
            update_dimension_settings ();
        });

        notify["grade"].connect (() => {
            update_grade_setting ();
        });

        notify["title"].connect (() => {
            update_title_setting ();
        });

        notify["strikeout-complete"].connect (() => {
            update_strikeout_setting ();
        });


    }

    public AppMenu () {
        image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        tooltip_text = _("Options");
    }

    private void update_dimension_settings () {
        row_setting.set_value (dimensions.rows ());
        column_setting.set_value (dimensions.cols ());
    }

    private void update_grade_setting () {
        grade_setting.set_value ((uint)grade);
    }

    private void update_title_setting () {
        title_setting.set_text (title);
    }

    private void update_strikeout_setting () {
        strikeout_setting.set_state (strikeout_complete);
    }

    private void update_properties () {
        var rows = (uint)(row_setting.get_value ());
        var cols = (uint)(column_setting.get_value ());
        dimensions = {cols, rows};
        grade = (Difficulty)(grade_setting.get_value ());
        title = title_setting.get_text ();
        strikeout_complete = strikeout_setting.get_state ();
    }

    private void add_setting (ref int pos, AppSetting setting) {
        var label = setting.get_heading ();
        label.xalign = 1;
        grid.attach (label, 0, pos, 1, 1);
        grid.attach (setting.get_chooser (), 1, pos, 1, 1);
        pos++;
    }

    /** Popover that can be cancelled with Escape and closed by Enter **/
    private class AppPopover : Gtk.Popover {
        private bool cancelled = false;
        public signal void apply_settings ();
        public signal void cancel ();

        construct {
            closed.connect (() => {
                if (!cancelled) {
                    apply_settings ();
                } else {
                    cancel ();
                }

                cancelled = false;
            });

            key_press_event.connect ((event) => {
                cancelled = (event.keyval == Gdk.Key.Escape);

                if (event.keyval == Gdk.Key.KP_Enter || event.keyval == Gdk.Key.Return) {
                    hide ();
                }
            });
        }

        public AppPopover (Gtk.Widget widget) {
            Object (relative_to: widget);
        }
    }

    /** Setting Widget using a Scale limited to integral values separated by step **/
    protected class ScaleGrid : AppSetting {
        public string heading {get; set;}
        public Gtk.Grid chooser {get; set;}
        public Gtk.Label heading_label {get; set;}
        public Gtk.Label val_label {get; set;}
        public AppScale scale {get; set;}

        construct {
            val_label = new Gtk.Label ("");
            chooser = new Gtk.Grid ();
            chooser.column_spacing = 6;
        }

        public ScaleGrid (string _heading, uint _start, uint _end, uint _step) {
            Object (heading: _heading);
            scale = new AppScale (_start, _end, _step);
            scale.expand = false;

            ((Gtk.Widget)scale).valign = Gtk.Align.START;

            scale.value_changed.connect (() => {
                var val = (uint)(scale.get_value ());
                val_label.label = val.to_string ();
            });

            heading_label = new Gtk.Label (heading);
            val_label.xalign = 0;

            chooser.attach (scale, 0, 0, 1, 1);
            chooser.attach (val_label, 1, 0, 1, 1);
        }

        public override void set_value (uint val) {
            scale.set_value (val);
            val_label.label = scale.get_value ().to_string ();
        }

        public override uint get_value () {
            return scale.get_value ();
        }

        public override Gtk.Label get_heading () {
            return heading_label;
        }

        public override Gtk.Widget get_chooser () {
            return chooser;
        }

        protected class AppScale : Gtk.Scale {
            private uint step;

            public AppScale (uint _start, uint _end, uint _step) {
                var start = (double)_start / (double)_step;
                var end = (double)_end / (double)_step + 1.0;
                step = _step;
                adjustment = new Gtk.Adjustment (start, start, end, 1.0, 1.0, 1.0);

                for (var val = start; val <= end; val += 1.0) {
                    add_mark (val, Gtk.PositionType.BOTTOM, null);
                }

                hexpand = true;
                draw_value = false;

                set_size_request ((int)(end - start) * 20, -1);
            }

            public new uint get_value () {
                return (uint)(base.get_value () + 0.3) * step;
            }

            public new void set_value (uint val) {
                base.set_value ((double)val / (double)step);
                value_changed ();
            }
        }
    }

    protected class GradeChooser : AppSetting {
        Gtk.ComboBoxText cb;
        Gtk.Label heading;

        construct {
            cb = new Gtk.ComboBoxText ();

            foreach (Difficulty d in Difficulty.all_human ()) {
                cb.append (((uint)d).to_string (), d.to_string ());
            }

            cb.expand = false;
            heading = new Gtk.Label (_("Generated games"));
        }

        public override void set_value (uint grade) {
            cb.active_id = grade.clamp (MIN_GRADE, Difficulty.MAXIMUM).to_string ();
        }

        public override uint get_value () {
            return (uint)(int.parse (cb.active_id));
        }

        public override Gtk.Label get_heading () {
            return heading;
        }

        public override Gtk.Widget get_chooser () {
            return cb;
        }
    }

    protected class TitleEntry : AppSetting {
        Gtk.Entry entry;
        Gtk.Label heading;

        construct {
            entry = new Gtk.Entry ();
            entry.placeholder_text = _("Enter title of game here");
            heading = new Gtk.Label (_("Title"));
        }

        public override Gtk.Label get_heading () {return heading;}

        public override Gtk.Widget get_chooser () {return entry;}

        public override unowned string get_text () {return entry.text;}
        public override void set_text (string text) {
            entry.text = text;
        }
    }

    protected class SettingSwitch : AppSetting {
        public Gtk.Switch @switch {get; construct;}
        public Gtk.Label label {get; construct;}

        construct {
            @switch = new Gtk.Switch ();
            @switch.halign = Gtk.Align.START;
            @switch.hexpand = false;
            @switch.state = false;
        }

        public SettingSwitch (string heading) {
            Object (
                label: new Gtk.Label (heading)
            );
        }

        public override Gtk.Label get_heading () {return label;}
        public override Gtk.Widget get_chooser () {return @switch;}

        public override bool get_state () {return @switch.state;}
        public override void set_state (bool state) {@switch.state = state;}

    }

    protected abstract class AppSetting : Object {
        public virtual void set_value (uint val) {return;}
        public virtual uint get_value () {return 0;}
        public virtual void set_state (bool active) {return;}
        public virtual bool get_state () {return false;}
        public virtual void set_text (string text) {}
        public virtual unowned string get_text () {return "";}
        public abstract Gtk.Label get_heading ();
        public abstract Gtk.Widget get_chooser ();
    }
}
}
