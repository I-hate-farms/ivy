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

 /** 
  * Provides services to display vala stacktraces
  */
namespace Meadows.Stacktrace {

    internal enum Style {
        RESET = 0,
        BRIGHT = 1,
        DIM = 2,
        UNDERLINE = 3,
        BLINK = 4,
        REVERSE = 7,
        HIDDEN = 8
    }

    /** 
     * Defines how Unix signals are processed
     */
    public enum CriticalHandler {
        /**
         * Unix signals are ignored 
         */
        IGNORE,
        /**
         * When a signal is intercepted, a stacktrace is displayed 
         * to ``stdout`` and the execution of the application is 
         * resumed 
         */        
        PRINT_STACKTRACE,
        /**
         * When a signal is intercepted, a stacktrace is displayed 
         * to ``stdout`` and  the application is stopped
         */                
        CRASH
    }

    /**
     * Colors used for displaying stacktraces  
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
     * A complete execution stacktrace
     *
     * Holds a collection of {@link Frame} and the basic methods to intercept Unix signals
     * and prints the complete stacktrace to ``stdout`` in colors.
     * 
     * For more information, refer to the [[https://github.com/I-hate-farms/stacktrace|official website]].
     *
     * Here's a sample of a printed stacktrace: 
     * {{{
     * An error occured (SIGSEGV) in samples/vala_file.vala, line 21 in 'this_will_crash_harder'
     * The reason is likely a null reference being used.
     *
     *    #1  <unknown>                                   in 'strlen'
     *        at /lib/x86_64-linux-gnu/libc.so.6
     * *  #2  samples/vala_file.vala             line  21 in 'this_will_crash_harder'               
     *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/vala_file.vala:21
     *    #3  samples/module/OtherModule.vala    line  11 in 'other_module_do_it'
     *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/module/OtherModule.vala:11
     *    #4  samples/error_sigsegv.vala         line  19 in 'namespace_someclass_exec'
     *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/error_sigsegv.vala:19
     *    #5  samples/error_sigsegv.vala         line  29 in 'this_will_crash'
     *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/error_sigsegv.vala:29
     *    #6  samples/error_sigsegv.vala         line  39 in '_vala_main'
     *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/samples/error_sigsegv.vala:39
     *    #7  error_sigsegv.vala.c               line 421 in 'main'
     *        at /home/cran/Documents/Projects/i-hate-farms/stacktrace/error_sigsegv.vala.c:421
     *    #8  <unknown>                                   in '__libc_start_main'
     *        at /lib/x86_64-linux-gnu/libc.so.6
     * }}}
     */
    public class Stacktrace {

        internal Frame first_vala = null;

        internal int max_file_name_length = 0;

        internal int max_line_number_length = 0;

        internal bool is_all_function_name_blank = true;

        internal bool is_all_file_name_blank = true;
        
        private Gee.ArrayList<Frame> _frames = new Gee.ArrayList<Frame>();

        /**
         * Unix signal being intercepted 
         * 
         */
        public ProcessSignal sig;

        /**
         * Enables the Unix signals interception
         *
         * Setting it to false and preventing signals interception and the collection
         * of the complete stacktrace (that might a significant effect on performance)
         * is useful when the application uses a library that emits a ``SIGTRAP``
         * signal for unknown reasons.
         * 
         * Such a case would cripple the application performance and clutter the 
         * ``stdout`` ouput for no benefit.
         *
         * Default is ``true`` 
         */
        public static bool enabled { get;set;default = true;}

        /**
         * Hides frames located in external system libraries (like ``libgc``) without 
         * code information 
         *
         * * Default is ``false`` 
         */        
        public static bool hide_installed_libraries { get;set;default = false;}

        /**
         * Sets the default higlighted text color for stacktrace that are created 
         * via Unix signals interception
         * 
         * Default is ``Color.WHITE``
         */
        public static Color default_highlight_color { get;set;default = Color.WHITE;}

        /**
         * Sets the default background color for stacktrace that are created 
         * via Unix signals interception
         * 
         * Default is ``Color.RED``
         */
         public static Color default_error_background { get;set;default = Color.RED;}

        /**
         * Sets the stacktrace higlighted text color when printed on ``stdout``
         * 
         * Default is ``Color.WHITE``
         */
         public Color highlight_color { get;set;default = Color.WHITE;}

        /**
         * Sets the stacktrace background color when printed on ``stdout``
         * 
         * Default is ``Color.RED``
         */
        public Color error_background { get;set;default = Color.RED;}

        /**
         * Collection of frames
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
         * Returns true if the stacktrace is "custom"
         * 
         * A custom stacktrace has been created via code as 
         * opposed to created via Unix signal interception.
         * 
         * Custom stacktrace are displayed with a different color scheme (default ``Color.GREEN``) that 
         * can be set via {@link highlight_color} and {@link error_background}
         * 
         * Here's how to create a custom stacktrace: 
         * {{{
         *   
         *   int my_function (string arg) {
         *      var custom_stracktrace = new Stacktrace () ;
         *      custom_stracktrace.print () ;
         *      return 0;
         *   }
         * }}}
         */
        public bool is_custom {
            get {
                return sig == ProcessSignal.TTOU;
            }
        }

        /**
         * Prints the stacktrace to ``stdout`` with colors 
         * 
         */
        public void print () {
           printer.print (this) ;
        }

        /**
         * Registers handlers to intercept Unix signals
         *
         * Calling ``register_handlers`` is required for the 
         * library to display a stacktrace when the application encounters an error (ie raises a ``SIGABRT``, 
         * a ``SIGSEV`` or a ``SIGTRAP`` signal).
         *
         * ''Note:'' calling ``register_handlers`` is not needed to be able to display custom stacktraces. <<BR>>
         * (See {@link is_custom} for more information about custom stacktraces).
         * 
         * How to initialize the library so it can intercept Unix signals:
         * {{{
         *   
         *   static int main (string[] arg) {
         *      Stacktrace.register_handlers ();
         *      // Start your application
         *      ... 
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
         * Defines how Unix signals are processed 
         * 
         * Default is ``CriticalHandler.PRINT_STACKTRACE``.
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
