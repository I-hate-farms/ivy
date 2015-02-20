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

    public class Frame {
        // Address used by addr2line
        public string address  { get;private set;default = "";}

        public string line { get;private set;default = "";}

        public string line_number { get;private set;default = "";}

        public string file_path { get;private set;default = "";}

        public string file_short_path { get;private set;default = "";}

        public string function { get;private set;default = "";}

        public Frame (string address, string line, string function, string file_path, string file_short_path) {
            this._address = address;
            this._line = line;

            this._file_path = file_path;
            this._file_short_path = file_short_path;
            this._function = function;
            // TODO
            this.line_number = Extractor.extract_line (line);
        }

        public string to_string () {
            var result = line;
            if (result == "")
                result = " C library at address [" + address + "]";
            return result + " [" + address + "]";
        }

    }

}
