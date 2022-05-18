"""
Copyright (c) 2020, 2021 Red Hat, IBM Corporation and others.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import json


def get_all_tunables():
    """
    Query Autotune API for the application_name, direction, hpo_algo_impl, id, objective_function, tunables and
    value_type, and return them.

    Returns:
        application_name (str): The name of the application that is being optimized.
        direction (str): Direction of optimization, minimize or maximize.
        hpo_algo_impl (str): Hyperparameter optimization library to perform Bayesian Optimization.
        id (str): The id of the application that is being optimized.
        objective_function (str): The objective function that is being optimized.
        tunables (list): A list containing the details of each tunable in a dictionary format.
        value_type (string): Value type of the objective function.
    """
    # JSON returned by the Autotune API
    # Placeholder code until the actual API parsing code is added
    # {"name": "cpuRequest", "value_type": ' \
    #                    '"double", "upper_bound": 4, "lower_bound": 1, "step": 0.01}, {"name": "memoryRequest", ' \
    #                    '"value_type": "integer", "upper_bound": 4096, "lower_bound": 270, "step": 1} , 
    # {"name": "cpuRequest", "value_type": ' \
    #                    '"double", "upper_bound": 8, "lower_bound": 1, "step": 0.1}, {"name": "memoryRequest", ' \
    #                    '"value_type": "integer", "upper_bound": 4096, "lower_bound": 270, "step": 1} ,
    search_space_json = '{"id": "auto123", "application_name": "tfb-qrh-deployment-6d4c8678d4-jmz8x", ' \
                        '"objective_function": "transaction_response_time", "value_type": "double", "direction": ' \
                        '"maximize", "hpo_algo_impl": "optuna_tpe", "tunables": [ {"name": "gcpolicy", ' \
                        '"value_type": "categorical", "choices": ["UseG1GC", "UseParallelGC", "UseSerialGC", "UseShenandoahGC"]}, {"name": "quarkusthreadpoolcorethreads", ' \
                        '"value_type": "integer", "upper_bound": 33, "lower_bound": 1, "step": 4}, {"name": "quarkusthreadpoolqueuesize", ' \
                        '"value_type": "integer", "upper_bound": 10000, "lower_bound": 0, "step": 10}, {"name": "quarkusdatasourcejdbcminsize", ' \
                        '"value_type": "integer", "upper_bound": 12, "lower_bound": 1, "step": 1}, {"name": "quarkusdatasourcejdbcmaxsize", ' \
                        '"value_type": "integer", "upper_bound": 90, "lower_bound": 12, "step": 1}, {"name": "FreqInlineSize", ' \
                        '"value_type": "integer", "upper_bound": 500, "lower_bound": 325, "step": 1}, {"name": "MaxInlineLevel", ' \
                        '"value_type": "integer", "upper_bound": 50, "lower_bound": 9, "step": 1}, {"name": "MinInliningThreshold", ' \
                        '"value_type": "integer", "upper_bound": 200, "lower_bound": 0, "step": 1}, {"name": "CompileThreshold", ' \
                        '"value_type": "integer", "upper_bound": 10000, "lower_bound": 1000, "step": 10}, {"name": "CompileThresholdScaling", ' \
                        '"value_type": "double", "upper_bound": 15, "lower_bound": 1, "step": 0.1}, {"name": "ConcGCThreads", ' \
                        '"value_type": "integer", "upper_bound": 8, "lower_bound": 1, "step": 1}, {"name": "InlineSmallCode", ' \
                        '"value_type": "integer", "upper_bound": 5000, "lower_bound": 500, "step": 1}, {"name": "LoopUnrollLimit", ' \
                        '"value_type": "integer", "upper_bound": 250, "lower_bound": 20, "step": 1}, {"name": "LoopUnrollMin", ' \
                        '"value_type": "integer", "upper_bound": 20, "lower_bound": 0, "step": 1}, {"name": "MinSurvivorRatio", ' \
                        '"value_type": "integer", "upper_bound": 48, "lower_bound": 3, "step": 1}, {"name": "NewRatio", ' \
                        '"value_type": "integer", "upper_bound": 10, "lower_bound": 1, "step": 1}, {"name": "TieredStopAtLevel", ' \
                        '"value_type": "integer", "upper_bound": 4, "lower_bound": 0, "step": 1}, {"name": "TieredCompilation", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "AllowParallelDefineClass", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "AllowVectorizeOnDemand", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "AlwaysCompileLoopMethods", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "AlwaysPreTouch", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "AlwaysTenure", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "BackgroundCompilation", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "DoEscapeAnalysis", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "UseInlineCaches", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "UseLoopPredicate", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "UseStringDeduplication", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "UseSuperWord", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "UseTypeSpeculation", ' \
                        '"value_type": "categorical", "choices": ["true", "false"]}, {"name": "StackTraceInThrowable", ' \
			'"value_type": "categorical", "choices": ["true", "false"]}, {"name": "checkBounds", ' \
			'"value_type": "categorical", "choices": ["true", "false"]}, {"name": "httpiothreads", ' \
			'"value_type": "categorical", "choices": ["true", "false"]}]} '

    search_space = json.loads(search_space_json)
    id = search_space["id"]
    application_name = search_space["application_name"]
    objective_function = search_space["objective_function"]
    value_type = search_space["value_type"]
    direction = search_space["direction"]
    hpo_algo_impl = search_space["hpo_algo_impl"]
    tunables = search_space["tunables"]
    return application_name, direction, hpo_algo_impl, id, objective_function, tunables, value_type
