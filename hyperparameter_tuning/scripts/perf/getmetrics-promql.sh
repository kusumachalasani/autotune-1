#!/bin/bash
#
# Copyright (c) 2020, 2021 IBM Corporation, RedHat and others.
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
### Script to get pod and cluster information through prometheus queries###
#
# checks if the previous command is executed successfully
# input:Return value of previous command
# output:Prompts the error message if the return value is not zero
function err_exit() 
{
	if [ $? != 0 ]; then
		printf "$*"
		echo 
		exit -1
	fi
}

## Collect CPU data
function get_cpu()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/cpu-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
#		echo "curl --silent -G -kH Authorization: Bearer ${TOKEN} --data-urlencode 'query=sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate) by (pod)' ${URL} "		 
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/cpu-${ITER}.json
		err_exit "Error: could not get cpu details of the pod" >>setup.log
	done
}

## Collect MEM_RSS
function get_mem_rss()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/mem-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(node_namespace_pod_container:container_memory_rss) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/mem-${ITER}.json
		err_exit "Error: could not get memory details of the pod" >>setup.log
	done
}

## Collect Memory Usage
function get_mem_usage()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/memusage-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(container_memory_working_set_bytes) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/memusage-${ITER}.json
		err_exit "Error: could not get memory details of the pod" >>setup.log
	done
}

## Collect network bytes received
function get_receive_bandwidth()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/receive_bandwidth-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(irate(container_network_receive_bytes_total[30s])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/receive_bandwidth-${ITER}.json
		err_exit "Error: could not get bandwidth details of the pod" >>setup.log
	done
}

## Collect network bytes transmitted
function get_transmit_bandwidth()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/transmit_bandwidth-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(irate(container_network_transmit_bytes_total[30s])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/transmit_bandwidth-${ITER}.json
		err_exit "Error: could not get bandwidth details of the pod" >>setup.log
	done
}

## Collect total seconds taken for timed annotations of all methods
function get_app_timer_sum()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/app_timer_sum-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(getop_timer_seconds_sum{exception="none"}) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_sum-${ITER}.json
		err_exit "Error: could not get app_timer_sum details of the pod" >>setup.log
	done
}

## Collect the total count of timed annotations of all methods
function get_app_timer_count()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/app_timer_count-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(getop_timer_seconds_count{exception="none"}) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_count-${ITER}.json
		err_exit "Error: could not get app_timer_count details of the pod" >>setup.log
	done
}

## Collect the total count of timed annotations of all methods
function get_app_timer_secondspercount()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/app_timer_secondspercount-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=(sum(increase(getop_timer_seconds_sum{exception="none"}[30s])) by (pod))/(sum(increase(getop_timer_seconds_count{exception="none"}[30s])) by (pod))' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_secondspercount-${ITER}.json
		err_exit "Error: could not get app_timer_secondspercount details of the pod" >>setup.log
	done
}

## Collect the max of timed annotation
function get_app_timer_max()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/app_timer_max-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(getop_timer_seconds_max{exception="none"}) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_max-${ITER}.json
		err_exit "Error: could not get app_timer_max details of the pod" >>setup.log
	done
}

## Collect the timed annotation seconds for individual methods
function get_app_timer_method_sum()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/app_timer_method_sum-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=getop_timer_seconds_sum{exception="none"}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .metric.method, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_method_sum-${ITER}.json
		err_exit "Error: could not get app_timer_method_sum details of the pod" >>setup.log
	done
}

## Collect the timed annotation count for individual methods
function get_app_timer_method_count()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/app_timer_method_count-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=getop_timer_seconds_count{exception="none"}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.method, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_method_count-${ITER}.json
		err_exit "Error: could not get app_timer_metod_count details of the pod" >>setup.log
	done
}

## Collect the max of timed annotation for each method
function get_app_timer_method_max()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/app_timer_method_max-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=getop_timer_seconds_max{exception="none"}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.method, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_method_max-${ITER}.json
		err_exit "Error: could not get app_timer_method_max details of the pod" >>setup.log
	done
}

## Collect server errors
function get_server_errors()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/server_errors-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(http_server_errors_total) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_errors-${ITER}.json
		err_exit "Error: could not get server error details of the pod" >>setup.log
	done
}

## Collect http_server_requests_sum seconds for all methods
function get_server_requests_sum()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/server_requests_sum-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(http_server_requests_seconds_sum) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum-${ITER}.json
		# err_exit "Error: could not get server_requests_sum details of the pod" >>setup.log
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(http_server_requests_seconds_sum) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' >> ${RESULTS_DIR}/server_requests_sum_all-${ITER}.json
	done
}

## Collect server_requests_count for all methods
function get_server_requests_count()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/server_requests_count-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(http_server_requests_seconds_count) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count-${ITER}.json
		err_exit "Error: could not get server_requests_count details of the pod" >>setup.log
	done
}

## Collect server_requests_max of all methods
function get_server_requests_max()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/server_requests_max-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(http_server_requests_seconds_max) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_max-${ITER}.json
		err_exit "Error: could not get server_requests_max details of the pod" >>setup.log
	done
}

## Collect server_requests_sum seconds for individual method
function get_server_requests_method_sum()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/server_requests_method_sum-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds_sum' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .metric.outcome, .metric.status, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_method_sum-${ITER}.json
		err_exit "Error: could not get server_requests_method_sum details of the pod" >>setup.log
	done
}

## Collect server_requests_count for individual methods
function get_server_requests_method_count()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/server_requests_method_count-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds_count' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .metric.outcome, .metric.status, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_method_count-${ITER}.json
		err_exit "Error: could not get server_requests_method_count details of the pod" >>setup.log
	done
}

## Collect server_Requests_max for all methods
function get_server_requests_method_max()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Delete the old json file if any
	rm -rf ${RESULTS_DIR}/server_requests_method_max-${ITER}.json
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds_max' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .metric.outcome , .metric.status, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_method_max-${ITER}.json
		err_exit "Error: could not get server_requests_method_max details of the pod" >>setup.log
	done
}

## Collect per second app_timer_seconds for last 1,3,5,7,9,15 and 30 mins.
function get_app_timer_sum_rate()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Processing curl output "timestamp value" using jq tool.
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_sum{exception="none"}[1m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_sum_rate_1m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_sum{exception="none"}[3m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_sum_rate_3m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_sum{exception="none"}[5m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_sum_rate_5m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_sum{exception="none"}[7m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_sum_rate_7m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_sum{exception="none"}[9m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_sum_rate_9m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_sum{exception="none"}[15m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_sum_rate_15m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_sum{exception="none"}[30m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_sum_rate_30m-${ITER}.json
}

## Collect per second app_timer_count for last 1,3,5,7,9,15 and 30 mins.
function get_app_timer_count_rate()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Processing curl output "timestamp value" using jq tool.
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_count{exception="none"}[1m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_count_rate_1m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_count{exception="none"}[3m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_count_rate_3m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_count{exception="none"}[5m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_count_rate_5m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_count{exception="none"}[7m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_count_rate_7m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_count{exception="none"}[9m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_count_rate_9m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_count{exception="none"}[15m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_count_rate_15m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(getop_timer_seconds_count{exception="none"}[30m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/app_timer_count_rate_30m-${ITER}.json

}

#### Collect per server_requests_sum for last 1,3,5,7,9,15 and 30 mins.
function get_server_requests_sum_rate()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Processing curl output "timestamp value" using jq tool.
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_sum[1m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum_rate_1m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_sum[3m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum_rate_3m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_sum[5m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum_rate_5m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_sum[7m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum_rate_7m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_sum[9m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum_rate_9m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_sum[15m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum_rate_15m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_sum[30m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum_rate_30m-${ITER}.json
}

## Collect per second server_requests_count for last 1,3,5,7,9,15 and 30 mins.
function get_server_requests_count_rate()
{
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	# Processing curl output "timestamp value" using jq tool.
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_count[1m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count_rate_1m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_count[3m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count_rate_3m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_count[5m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count_rate_5m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_count[7m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count_rate_7m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_count[9m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count_rate_9m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_count[15m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count_rate_15m-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=sum(rate(http_server_requests_seconds_count[30m])) by (pod)' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count_rate_30m-${ITER}.json

}

#### Collect per server_requests_sum for last 1,3,5,7,9,15 and 30 mins.
function get_server_requests_sum_rate_uri()
{
        URL=$1
        TOKEN=$2
        RESULTS_DIR=$3
        ITER=$4
        APP_NAME=$5
        # Processing curl output "timestamp value" using jq tool.
        curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=rate(http_server_requests_seconds_sum{uri="/db"}[1m])' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum_rate_1m_uri-${ITER}.json
        curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=rate(http_server_requests_seconds_sum{uri="/db"}[3m])' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_sum_rate_3m_uri-${ITER}.json
}

## Collect per second server_requests_count for last 1,3,5,7,9,15 and 30 mins.
function get_server_requests_count_rate_uri()
{
        URL=$1
        TOKEN=$2
        RESULTS_DIR=$3
        ITER=$4
        APP_NAME=$5
        # Processing curl output "timestamp value" using jq tool.
        curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=rate(http_server_requests_seconds_count{uri="/db"}[1m])' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count_rate_1m_uri-${ITER}.json
        curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=rate(http_server_requests_seconds_count{uri="/db"}[3m])' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/server_requests_count_rate_3m_uri-${ITER}.json

}

function get_latency_quantiles() {

	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	while true
	do
	# Processing curl output "timestamp value" using jq tool.
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=latency_seconds{quantile="0.5",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/latency_seconds_quan_50-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=latency_seconds{quantile="0.95",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/latency_seconds_quan_95-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=latency_seconds{quantile="0.98",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/latency_seconds_quan_98-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=latency_seconds{quantile="0.99",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/latency_seconds_quan_99-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=latency_seconds{quantile="0.999",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/latency_seconds_quan_999-${ITER}.json
	done
}

function get_latency_max() {
	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	while true
	do
		# Processing curl output "timestamp value" using jq tool.
		curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=latency_seconds_max' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/latency_seconds_max-${ITER}.json
	done
}

function get_http_quantiles() {

	URL=$1
	TOKEN=$2
	RESULTS_DIR=$3
	ITER=$4
	APP_NAME=$5
	
	# Processing curl output "timestamp value" using jq tool.
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds{status="200",uri="/db",quantile="0.5",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_50-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds{status="200",uri="/db",quantile="0.75",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_75-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds{status="200",uri="/db",quantile="0.95",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_95-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds{status="200",uri="/db",quantile="0.97",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_97-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds{status="200",uri="/db",quantile="0.99",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_99-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds{status="200",uri="/db",quantile="0.999",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_999-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds{status="200",uri="/db",quantile="0.9999",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_9999-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=http_server_requests_seconds{status="200",uri="/db",quantile="0.99999",}' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_99999-${ITER}.json

	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=histogram_quantile(0.50, sum(rate(http_server_requests_seconds_bucket{uri="/db"}[3m])) by (le))' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_50_histo-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=histogram_quantile(0.75, sum(rate(http_server_requests_seconds_bucket{uri="/db"}[3m])) by (le))' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_75_histo-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket{uri="/db"}[3m])) by (le))' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_95_histo-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=histogram_quantile(0.97, sum(rate(http_server_requests_seconds_bucket{uri="/db"}[3m])) by (le))' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_97_histo-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=histogram_quantile(0.99, sum(rate(http_server_requests_seconds_bucket{uri="/db"}[3m])) by (le))' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_99_histo-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=histogram_quantile(0.999, sum(rate(http_server_requests_seconds_bucket{uri="/db"}[3m])) by (le))' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_999_histo-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=histogram_quantile(0.9999, sum(rate(http_server_requests_seconds_bucket{uri="/db"}[3m])) by (le))' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_9999_histo-${ITER}.json
	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=histogram_quantile(0.99999, sum(rate(http_server_requests_seconds_bucket{uri="/db"}[3m])) by (le))' ${URL} | jq '[ .data.result[] | [ .value[0], .metric.namespace, .metric.pod, .value[1]|tostring] | join(";") ]' | grep "${APP_NAME}" >> ${RESULTS_DIR}/http_seconds_quan_99999_histo-${ITER}.json

	curl --silent -G -kH "Authorization: Bearer ${TOKEN}" --data-urlencode 'query=histogram_quantile(0.50, sum(rate(http_server_requests_seconds_bucket{uri="/db"}[3m])) by (le))' ${URL} >> ${RESULTS_DIR}/http_seconds_quan_50_histo-all.json
	
}


ITER=$1
TIMEOUT=$2
RESULTS_DIR=$3
mkdir -p ${RESULTS_DIR}
#QUERY_APP=prometheus-k8s-openshift-monitoring.apps
QUERY_APP=thanos-querier-openshift-monitoring.apps
BENCHMARK_SERVER=$4
APP_NAME=$5
URL=https://${QUERY_APP}.${BENCHMARK_SERVER}/api/v1/query
TOKEN=`oc whoami --show-token`

export -f err_exit get_cpu get_mem_rss get_mem_usage get_receive_bandwidth get_transmit_bandwidth
export -f get_app_timer_sum get_app_timer_count get_app_timer_secondspercount get_app_timer_max get_server_errors get_server_requests_sum get_server_requests_count get_server_requests_max 
export -f get_app_timer_method_sum get_app_timer_method_count get_app_timer_method_max get_server_requests_method_sum get_server_requests_method_count get_server_requests_method_max
export -f get_latency_quantiles get_latency_max

echo "Collecting metric data" >> setup.log
timeout ${TIMEOUT} bash -c  "get_cpu ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
timeout ${TIMEOUT} bash -c  "get_mem_rss ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
timeout ${TIMEOUT} bash -c  "get_mem_usage ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_receive_bandwidth ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_transmit_bandwidth ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_app_timer_sum ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_app_timer_count ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_app_timer_secondspercount ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_app_timer_max ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
timeout ${TIMEOUT} bash -c  "get_server_errors ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
timeout ${TIMEOUT} bash -c  "get_server_requests_sum ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
timeout ${TIMEOUT} bash -c  "get_server_requests_count ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
timeout ${TIMEOUT} bash -c  "get_server_requests_max ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_app_timer_method_sum ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_app_timer_method_count ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_app_timer_method_max ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_server_requests_method_sum ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_server_requests_method_count ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_server_requests_method_max ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_latency_quantiles ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
#timeout ${TIMEOUT} bash -c  "get_latency_max ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME}" &
sleep ${TIMEOUT}

# Calculate the rate of metrics for the last 1,3,5,7,9,15,30 mins.
#get_app_timer_sum_rate ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME} &
#get_app_timer_count_rate ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME} &
get_server_requests_sum_rate ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME} &
get_server_requests_count_rate ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME} &
get_http_quantiles ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME} &

get_server_requests_sum_rate_uri ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME} &
get_server_requests_count_rate_uri ${URL} ${TOKEN} ${RESULTS_DIR} ${ITER} ${APP_NAME} &

