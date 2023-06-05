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

import os


from implem.calls_ana_simu import call_hibou_analysis
from implem.calls_ana_nfa import call_nfa_analysis
from implem.commons import FOLDER_MODEL
from implem.trace_kinds import GlobalTraceKind




def analysis_process(int_name,num_tries,timeout_accept,timeout_error):
    f = open("{}.csv".format(int_name), "w")
    f.truncate(0)  # empty file
    columns = ["name",
               "kind",
               "trace_length",
               "hibou_time_tries",
               "hibou_time_median",
               "hibou_verdict",
               'hibou_rate',
               "nfa_time_tries",
               "nfa_time_median",
               "nfa_verdict",
               'nfa_rate']
    f.write(";".join(columns) + "\n")
    f.flush()
    #
    kinds = [(GlobalTraceKind.ACCEPTED,timeout_accept),(GlobalTraceKind.ERROR,timeout_error)]
    #
    hsf_file = os.path.join(FOLDER_MODEL, "{}.hsf".format(int_name))
    hif_file = os.path.join(FOLDER_MODEL, "{}.hif".format(int_name))
    #
    for (kind,timeout) in kinds:
        print("analyzing {} traces for {}".format(kind.kind_repr(), int_name))
        folder = kind.get_tracegen_folder_name(int_name)
        for htf_file in os.listdir(folder):
            htf_file_name = htf_file[:-4]
            htf_file = os.path.join(folder, htf_file)
            #
            hibou_dict = call_hibou_analysis(hsf_file, hif_file, htf_file, kind, num_tries, timeout)
            nfa_dict = call_nfa_analysis(hsf_file,hif_file,htf_file,num_tries)
            #
            #print("trace length " + str(nfa_dict['trace_length']))
            #
            #print("hibou time " + str(hibou_dict['hibou_time_median']))
            if hibou_dict['hibou_time_median'] == None:
                hibou_rate = None
            else:
                hibou_rate = float(hibou_dict['hibou_time_median']) / float(nfa_dict['trace_length'])
            #print("hibou rate " + str(hibou_rate))
            #
            #print("nfa time " + str(nfa_dict['nfa_time_median']))
            nfa_rate = float(nfa_dict['nfa_time_median']) / float(nfa_dict['trace_length'])
            #print("nfa rate " + str(nfa_rate))
            #
            f.write("{};{};{};{};{};{};{};{};{};{};{}\n".format(htf_file_name,
                                                        kind.kind_repr(),
                                                         nfa_dict['trace_length'],
                                                         hibou_dict['hibou_time_tries'],
                                                         hibou_dict['hibou_time_median'],
                                                         hibou_dict['hibou_verdict'],
                                                                hibou_rate,
                                                         nfa_dict['nfa_time_tries'],
                                                         nfa_dict['nfa_time_median'],
                                                         nfa_dict['nfa_verdict'],nfa_rate))
            f.flush()



