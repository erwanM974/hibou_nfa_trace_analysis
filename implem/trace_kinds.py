#
# Copyright 2023 Erwan Mahe (github.com/erwanM974)
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from enum import IntEnum

class GlobalTraceKind(IntEnum):
    ACCEPTED = 1
    ERROR = 2

    def kind_repr(self):
        if self == GlobalTraceKind.ACCEPTED:
            return "ACP"
        elif self == GlobalTraceKind.ERROR:
            return "ERR"

    def get_tracegen_folder_name(self, int_name):
        if self == GlobalTraceKind.ACCEPTED:
            return "tracegen_{}_explo".format(int_name)
        elif self == GlobalTraceKind.ERROR:
            return "tracegen_{}_error".format(int_name)
