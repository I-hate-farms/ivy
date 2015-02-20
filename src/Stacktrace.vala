/*
 * Copyright (C) 2014 PerfectCarl - https://github.com/PerfectCarl/vala-stacktrace
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* History
 *  - 1.4 :
 *        . investigating the get_media bug
 *  - 1.3 :
 *        . Optim: do not parse libraries that have no runtime
 *          info over and over
 *        . A library is something that contains the string ".so"
 *  - 1.2 :
 *        . Include elementary.cmake
 *  - 1.1 :
 *        . Support debugging in multiple .so
 *  - 1.0 : Oct, 18 2014
 *        . initial version
 *        . Header not displaying an error for user created stacktrace
 *        . Change spacing
 */
namespace Meadows.Stacktrace {

    public enum Style {
        RESET = 0,
        BRIGHT = 1,
        DIM = 2,
        UNDERLINE = 3,
        BLINK = 4,
        REVERSE = 7,
        HIDDEN = 8
    }

    public enum CriticalHandler {
        IGNORE,
        PRINT_STACKTRACE,
        CRASH
    }

    public enum Color {
        BLACK = 0,
        RED = 1,
        GREEN = 2,
        YELLOW = 3,
        BLUE = 4,
        MAGENTA = 5,
        CYAN = 6,
        WHITE = 7
    }

    public class Stacktrace {

        public Gee.ArrayList<Frame> _frames = new Gee.ArrayList<Frame>();

        public Frame first_vala = null;

        public int max_file_name_length = 0;

        public int max_line_number_length = 0;

        public bool is_all_function_name_blank = true;

        public bool is_all_file_name_blank = true;

        public ProcessSignal sig;

        public static bool enabled { get;set;default = true;}

        public static bool hide_installed_libraries { get;set;default = false;}

        public static Color default_highlight_color { get;set;default = Color.WHITE;}

        public static Color default_error_background { get;set;default = Color.RED;}

        public Color highlight_color { get;set;default = Color.WHITE;}

        public Color error_background { get;set;default = Color.RED;}

        public Gee.ArrayList<Frame> frames {
            get {
                return _frames;
            }
        }

        private Printer printer = new Printer () ;
        private Extractor extractor = new Extractor () ;

        public Stacktrace (GLib.ProcessSignal sig = GLib.ProcessSignal.TTOU) {
            this.sig = sig;
            // The stacktrace is used likely to understand the inner
            // working of the app so we displays everything.
            if (is_custom) {
                hide_installed_libraries = false;
                error_background = Color.BLUE;
            } else {
                error_background = default_error_background;
                highlight_color = default_highlight_color;
            }
            extractor.create_stacktrace (this);
        }

        public bool is_custom {
            get {
                return sig == ProcessSignal.TTOU;
            }
        }

        public void print () {
           printer.print (this) ;
        }

        public static void register_handlers () {
            Log.set_always_fatal (LogLevelFlags.LEVEL_CRITICAL);

            Process.@signal (ProcessSignal.SEGV, handler);
            Process.@signal (ProcessSignal.TRAP, handler);
            if (critical_handling != CriticalHandler.IGNORE)
                Process.@signal (ProcessSignal.ABRT, handler);
        }

        public static CriticalHandler critical_handling  { get;set;default = CriticalHandler.PRINT_STACKTRACE;}

        /*{
            set {
                _critical_handling = value ;
                if( value == CriticalHandler.CRASH )
                //var variables = Environ.get ();
                //Environ.set_variable (variables, "G_DEBUG", "fatal-criticals" );
                Log.set_always_fatal (LogLevelFlags.LEVEL_CRITICAL);
            }
            get {
            }

           }*/

        public static void handler (int sig) {
            if( !enabled)
                return ;
            Stacktrace stack = new Stacktrace ((ProcessSignal) sig);
            stack.print ();
            if (sig != ProcessSignal.TRAP ||
                (sig == ProcessSignal.TRAP && critical_handling == CriticalHandler.CRASH))
                Process.exit (1);
        }

    }
}
