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

 /** 
  * COMMENTS RIGHT HERE, RIGHT NOW 
  */
namespace Meadows.Stacktrace {

    /**
     * First paragraph,
     * still the first paragraph
     *
     * Second paragraph, first line,<<BR>>
     * second paragraph, second line
     */
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

/**
 * ''bold'' //italic// __underlined__ ``block quote``,
 * ''//__bold italic underlined__//''
 */
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

/**
 * short description
 * 
 * {{{
 * An error occured (SIGSEGV) in samples/vala_file.vala, line 21 in 'this_will_crash_harder'
 *  The reason is likely a null reference being used.
 *
 *    #1  <unknown>                                    in 'strlen'
 *        at /lib/x86_64-linux-gnu/libc.so.6
 * *  #2  samples/vala_file.vala             line  21 in 'this_will_crash_harder'               
 *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/vala_file.vala:21
 *    #3  samples/module/OtherModule.vala    line  11 in 'other_module_do_it'
 *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/module/OtherModule.vala:11
 *    #4  samples/error_sigsegv.vala         line  19 in 'namespace_someclass_exec'
 *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/error_sigsegv.vala:19
 *    #5  samples/error_sigsegv.vala         line  29 in 'this_will_crash'
 *       at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/error_sigsegv.vala:29
 *    #6  samples/error_sigsegv.vala         line  39 in '_vala_main'
 *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/error_sigsegv.vala:39
 *    #7  error_sigsegv.vala.c               line 421 in 'main'
 *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/error_sigsegv.vala.c:421
 *    #8  <unknown>                                    in '__libc_start_main'
 *        at /lib/x86_64-linux-gnu/libc.so.6
 * }}}
 */
    public class Stacktrace {

        

        internal Frame first_vala = null;

        internal int max_file_name_length = 0;

        internal int max_line_number_length = 0;

        internal bool is_all_function_name_blank = true;

        internal bool is_all_file_name_blank = true;
        
        /**
         * Description 
         * 
         */
        public Gee.ArrayList<Frame> _frames = new Gee.ArrayList<Frame>();

        /**
         * Description 
         * 
         */
        public ProcessSignal sig;
        /**
         * Description 
         * 
         */
        public static bool enabled { get;set;default = true;}

        /**
         * Description 
         * 
         */        
        public static bool hide_installed_libraries { get;set;default = false;}

        /**
         * Description 
         * 
         */
        public static Color default_highlight_color { get;set;default = Color.WHITE;}

        /**
         * Description 
         * 
         */
         public static Color default_error_background { get;set;default = Color.RED;}

        /**
         * Description 
         * 
         */
         public Color highlight_color { get;set;default = Color.WHITE;}

        /**
         * Description 
         * 
         */
        public Color error_background { get;set;default = Color.RED;}

        /**
         * Description 
         * 
         */
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

        /**
         * Description 
         * 
         */
        public bool is_custom {
            get {
                return sig == ProcessSignal.TTOU;
            }
        }

        /**
         * Print the stacktrace to stdout with colors 
         * 
         */
        public void print () {
           printer.print (this) ;
        }

        /**
         * Registers handlers to intercept Unix signals. 
         *
         * Calling register_handlers is mandatory for Stacktrace to be able to 
         * able to display a stacktrace when the application encounters an error.
         *
         * It is not needed to be able to display a custom stacktrace like in the 
         * code below
         *
         * {{{
         *   
         *   static int main (string[] arg) {
         *      new Stacktrace ().print () ;
         *      return 0;
         *   }
         * }}}
         *
         */
        public static void register_handlers () {
            Log.set_always_fatal (LogLevelFlags.LEVEL_CRITICAL);

            Process.@signal (ProcessSignal.SEGV, handler);
            Process.@signal (ProcessSignal.TRAP, handler);
            if (critical_handling != CriticalHandler.IGNORE)
                Process.@signal (ProcessSignal.ABRT, handler);
        }

        /** 
         * Short description 
         */
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

        private static void handler (int sig) {
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
