#!/bin/bash
#
# Copyright (c) 2024, 2024 Red Hat, IBM Corporation and others.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
##### Script to perform basic tests for EM #####


# Get the absolute path of current directory
CURRENT_DIR="$(dirname "$(realpath "$0")")"
LOCAL_MONITORING_TEST_DIR="${CURRENT_DIR}/local_monitoring_tests"
METRIC_PROFILE_DIR="${LOCAL_MONITORING_TEST_DIR}/../../../manifests/autotune/performance-profiles"

# Source the common functions scripts
. ${LOCAL_MONITORING_TEST_DIR}/../common/common_functions.sh

# Tests to validate Local monitoring mode in Kruize
function local_monitoring_tests() {
	start_time=$(get_date)
	FAILED_CASES=()
	TESTS_FAILED=0
	TESTS_PASSED=0
	TESTS=0
	failed=0
	marker_options=""
	((TOTAL_TEST_SUITES++))

	python3 --version >/dev/null 2>/dev/null
	err_exit "ERROR: python3 not installed"

	target="crc"
	metric_profile_json="${METRIC_PROFILE_DIR}/resource_optimization_local_monitoring.json"

	local_monitoring_tests=("sanity" "extended" "negative" "test_e2e" "test_e2e_pr_check" "test_bulk_api_ros")

	# check if the test case is supported
	if [ ! -z "${testcase}" ]; then
		check_test_case "local_monitoring"
	fi

	# create the result directory for given testsuite
	echo ""
	TEST_SUITE_DIR="${RESULTS}/local_monitoring_tests"
	KRUIZE_SETUP_LOG="${TEST_SUITE_DIR}/kruize_setup.log"
	KRUIZE_POD_LOG="${TEST_SUITE_DIR}/kruize_pod.log"

	mkdir -p ${TEST_SUITE_DIR}

  # check for 'isROSEnabled' flag
  kruize_local_ros_patch
  # check for 'servicename' and 'datasource_namespace' input variables
  kruize_local_datasource_manifest_patch

	# Setup kruize
	if [ ${skip_setup} -eq 0 ]; then
		echo "Setting up kruize..." | tee -a ${LOG}
		echo "${KRUIZE_SETUP_LOG}"
		setup "${KRUIZE_POD_LOG}" >> ${KRUIZE_SETUP_LOG} 2>&1
	        echo "Setting up kruize...Done" | tee -a ${LOG}

		sleep 60

	else
		echo "Skipping kruize setup..." | tee -a ${LOG}
	fi

	# If testcase is not specified run all tests
	if [ -z "${testcase}" ]; then
		testtorun=("${local_monitoring_tests[@]}")
	else
		testtorun=${testcase}
	fi

	# create the result directory for given testsuite
	echo ""
	mkdir -p ${TEST_SUITE_DIR}

	PIP_INSTALL_LOG="${TEST_SUITE_DIR}/pip_install.log"

	echo ""
	echo "Installing the required python modules..."
	echo "python3 -m pip install --user -r "${LOCAL_MONITORING_TEST_DIR}/requirements.txt" > ${PIP_INSTALL_LOG}"
	#removing --user flag as facing error: "Can not perform a '--user' install. User site-packages are not visible in this virtualenv."
	python3 -m pip install -r "${LOCAL_MONITORING_TEST_DIR}/requirements.txt" > ${PIP_INSTALL_LOG} 2>&1
	err_exit "ERROR: Installing python modules for the test run failed!"

	echo ""
	echo "******************* Executing test suite ${FUNCNAME} ****************"
	echo ""

	for test in "${testtorun[@]}"
	do
		TEST_DIR="${TEST_SUITE_DIR}/${test}"
		mkdir ${TEST_DIR}
		LOG="${TEST_DIR}/${test}.log"

		echo ""
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" | tee -a ${LOG}
		echo "                    Running Test ${test}" | tee -a ${LOG}
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"| tee -a ${LOG}

		echo " " | tee -a ${LOG}
		echo "Test description: ${local_monitoring_test_description[$test]}" | tee -a ${LOG}
		echo " " | tee -a ${LOG}

		pushd ${LOCAL_MONITORING_TEST_DIR}/rest_apis > /dev/null
			echo "pytest -m ${test} --junitxml=${TEST_DIR}/report-${test}.xml --html=${TEST_DIR}/report-${test}.html --cluster_type ${cluster_type}"
			pytest -m ${test} --junitxml=${TEST_DIR}/report-${test}.xml --html=${TEST_DIR}/report-${test}.html --cluster_type ${cluster_type} | tee -a ${LOG}
			err_exit "ERROR: Running the test using pytest failed, check ${LOG} for details!"

		popd > /dev/null

		passed=$(grep -o -E '[0-9]+ passed' ${TEST_DIR}/report-${test}.html | cut -d' ' -f1)
		failed=$(grep -o -E 'check the boxes to filter the results.*' ${TEST_DIR}/report-${test}.html | grep -o -E '[0-9]+ failed' | cut -d' ' -f1)
		errors=$(grep -o -E '[0-9]+ errors' ${TEST_DIR}/report-${test}.html | cut -d' ' -f1)

		TESTS_PASSED=$(($TESTS_PASSED + $passed))
		TESTS_FAILED=$(($TESTS_FAILED + $failed))

		if [ "${errors}" -ne "0" ]; then
			echo "Tests did not execute there were errors, check the logs"
			exit 1
		fi

		if [ "${TESTS_FAILED}" -ne "0" ]; then
			FAILED_CASES+=(${test})
		fi

	done

	TESTS=$(($TESTS_PASSED + $TESTS_FAILED))
	TOTAL_TESTS_FAILED=${TESTS_FAILED}
	TOTAL_TESTS_PASSED=${TESTS_PASSED}
	TOTAL_TESTS=${TESTS}

	if [ "${TESTS_FAILED}" -ne "0" ]; then
		FAILED_TEST_SUITE+=(${FUNCNAME})
	fi

	end_time=$(get_date)
	elapsed_time=$(time_diff "${start_time}" "${end_time}")

	# Remove the duplicates
	FAILED_CASES=( $(printf '%s\n' "${FAILED_CASES[@]}" | uniq ) )

	# print the testsuite summary
	testsuitesummary ${FUNCNAME} ${elapsed_time} ${FAILED_CASES}
}
