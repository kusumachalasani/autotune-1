cpu_request=$1
memory_request=$2
gcpolicy=$3
quarkusthreadpoolcorethreads=$4
quarkusthreadpoolqueuesize=$5
quarkusdatasourcejdbcminsize=$6
quarkusdatasourcejdbcmaxsize=$7
FreqInlineSize=$8
MaxInlineLevel=$9
MinInliningThreshold=${10}
CompileThreshold=${11}
CompileThresholdScaling=${12}
ConcGCThreads=${13}
InlineSmallCode=${14}
LoopUnrollLimit=${15}
LoopUnrollMin=${16}
MinSurvivorRatio=${17}
NewRatio=${18}
TieredStopAtLevel=${19}
TieredCompilation=${20}
AllowParallelDefineClass=${21}
AllowVectorizeOnDemand=${22}
AlwaysCompileLoopMethods=${23}
AlwaysPreTouch=${24}
AlwaysTenure=${25}
BackgroundCompilation=${26}
DoEscapeAnalysis=${27}
UseInlineCaches=${28}
UseLoopPredicate=${29}
UseStringDeduplication=${30}
UseSuperWord=${31}
UseTypeSpeculation=${32}

./scripts/perf/tfb-run.sh --clustertype="openshift" -s ${BENCHMARK_SERVER} -e ${RESULTS_DIR} --dbtype=standalone --dbhost="10.1.45.55:5432" -r -d ${DURATION} -w ${WARMUPS} -m ${MEASURES} -i ${SERVER_INSTANCES} --iter=${ITERATIONS} -n ${NAMESPACE} -t ${THREADS} -R ${RATE} --connection=${CONNECTION} --cpureq=${cpu_request} --memreq=${memory_request}M --cpulim=${cpu_request} --memlim=${memory_request}M --gcpolicy=${gcpolicy} --quarkustpcorethreads=${quarkusthreadpoolcorethreads} --quarkustpqueuesize=${quarkusthreadpoolqueuesize} --quarkusdatasourcejdbcminsize=${quarkusdatasourcejdbcminsize} --quarkusdatasourcejdbcmaxsize=${quarkusdatasourcejdbcmaxsize} --FreqInlineSize=${FreqInlineSize} --MaxInlineLevel=${MaxInlineLevel} --MinInliningThreshold=${MinInliningThreshold} --CompileThreshold=${CompileThreshold} --CompileThresholdScaling=${CompileThresholdScaling} --ConcGCThreads=${ConcGCThreads} --InlineSmallCode=${InlineSmallCode} --LoopUnrollLimit=${LoopUnrollLimit} --LoopUnrollMin=${LoopUnrollMin} --MinSurvivorRatio=${MinSurvivorRatio} --NewRatio=${NewRatio} --TieredStopAtLevel=${TieredStopAtLevel} --TieredCompilation=${TieredCompilation} --AllowParallelDefineClass=${AllowParallelDefineClass} --AllowVectorizeOnDemand=${AllowVectorizeOnDemand} --AlwaysCompileLoopMethods=${AlwaysCompileLoopMethods} --AlwaysPreTouch=${AlwaysPreTouch} --AlwaysTenure=${AlwaysTenure} --BackgroundCompilation=${BackgroundCompilation} --DoEscapeAnalysis=${DoEscapeAnalysis} --UseInlineCaches=${UseInlineCaches} --UseLoopPredicate=${UseLoopPredicate} --UseStringDeduplication=${UseStringDeduplication} --UseSuperWord=${UseSuperWord} --UseTypeSpeculation=${UseTypeSpeculation}

# sleep 30

## Run the baseline
#./scripts/perf/tfb-run.sh --clustertype="openshift" -s ${BENCHMARK_SERVER} -e ${RESULTS_DIR} --dbtype=standalone --dbhost="10.1.45.55:5432" -r -d ${DURATION} -w ${WARMUPS} -m ${MEASURES} -i ${SERVER_INSTANCES} --iter=${ITERATIONS} -n ${NAMESPACE} -t ${THREADS} -R ${RATE} --connection=${CONNECTION} --cpureq=4 --memreq=4096M --cpulim=4 --memlim=4096M
