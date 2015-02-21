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

    /** 
     * This class represent on instance of a frame, ie a particular location 
     * in a binary (application or library) on the system called by the application
     *
     * Note: frames from system libraries without code information available are 
     * not displayed by default. See Stacktrace.hide_installed_libraries for how to
     * display them.   
     **/
    public class Frame {
        
        /**
         * Address of the stack in hexadecimal. 
         * Ex: 0x00EDE
         **/
        public string address  { get;private set;default = "";}
        
        /**
         * Line of code. Can point to C code, Vala code or be blank if 
         * no symbol is available (or if -rdynamic has not been set during the
         * compilation of the binary) 
         * Ex: 
         **/
        public string line { get;private set;default = "";}

        /**
         * Line number in the code file. May be blank if no code information is available 
         * Ex: 25
         **/
        public string line_number { get;private set;default = "";}

        /**
         * Full path to the code file as it was stored on the building machine. 
         * Returns the path to the installed binary if no code information is available 
         * Ex: ////
         **/
        public string file_path { get;private set;default = "";}
        
        /**
         * Path the code file relative to the current path. 
         * Returns the path to the installed binary if no code information is available  
         * Ex: ////
         **/
        public string file_short_path { get;private set;default = "";}

        /**
         * C Function name. 
         * 
         * Because only the C function name is avaialable, 
         * the name mixes the class and method name.
         * Ex: 
         **/       
        public string function { get;private set;default = "";}

        public Frame (string address, string line, string function, string file_path, string file_short_path, string line_number) {
            this._address = address;
            this._line = line;

            this._file_path = file_path;
            this._file_short_path = file_short_path;
            this._function = function;
            this.line_number = line_number ;
        }

        public string to_string () {
            var result = line;
            if (result == "")
                result = " C library at address [" + address + "]";
            return result + " [" + address + "]";
        }

    }

}
