cpu_request=$1
memory_request=$2
quarkusthreadpoolcorethreads=$3
quarkusthreadpoolqueuesize=$4
quarkusdatasourcejdbcminsize=$5
quarkusdatasourcejdbcmaxsize=$6
FreqInlineSize=$7
MaxInlineLevel=$8
MinInliningThreshold=$9
CompileThreshold=${10}
CompileThresholdScaling=${11}
ConcGCThreads=${12}
InlineSmallCode=${13}
LoopUnrollLimit=${14}
LoopUnrollMin=${15}
MinSurvivorRatio=${16}
NewRatio=${17}
TieredStopAtLevel=${18}
TieredCompilation=${19}
AllowParallelDefineClass=${20}
AllowVectorizeOnDemand=${21}
AlwaysCompileLoopMethods=${22}
AlwaysPreTouch=${23}
AlwaysTenure=${24}
BackgroundCompilation=${25}
DoEscapeAnalysis=${26}
UseInlineCaches=${27}
UseLoopPredicate=${28}
UseStringDeduplication=${29}
UseSuperWord=${30}
UseTypeSpeculation=${31}

./scripts/perf/run-tfb-qrh-openshift.sh -s ${BENCHMARK_SERVER} -e ${RESULTS_DIR} -r -d ${DURATION} -w ${WARMUPS} -m ${MEASURES} -i ${SERVER_INSTANCES} --iter=${ITERATIONS} -n ${NAMESPACE} -t ${THREADS} -R ${RATE} --connection=${CONNECTION} --cpureq=${cpu_request} --memreq=${memory_request}M --cpulim=${cpu_request} --memlim=${memory_request}M --quarkustpcorethreads=${quarkusthreadpoolcorethreads} --quarkustpqueuesize=${quarkusthreadpoolqueuesize} --quarkusdatasourcejdbcminsize=${quarkusdatasourcejdbcminsize} --quarkusdatasourcejdbcmaxsize=${quarkusdatasourcejdbcmaxsize} --FreqInlineSize=${FreqInlineSize} --MaxInlineLevel=${MaxInlineLevel} --MinInliningThreshold=${MinInliningThreshold} --CompileThreshold=${CompileThreshold} --CompileThresholdScaling=${CompileThresholdScaling} --ConcGCThreads=${ConcGCThreads} --InlineSmallCode=${InlineSmallCode} --LoopUnrollLimit=${LoopUnrollLimit} --LoopUnrollMin=${LoopUnrollMin} --MinSurvivorRatio=${MinSurvivorRatio} --NewRatio=${NewRatio} --TieredStopAtLevel=${TieredStopAtLevel} --TieredCompilation=${TieredCompilation} --AllowParallelDefineClass=${AllowParallelDefineClass} --AllowVectorizeOnDemand=${AllowVectorizeOnDemand} --AlwaysCompileLoopMethods=${AlwaysCompileLoopMethods} --AlwaysPreTouch=${AlwaysPreTouch} --AlwaysTenure=${AlwaysTenure} --BackgroundCompilation=${BackgroundCompilation} --DoEscapeAnalysis=${DoEscapeAnalysis} --UseInlineCaches=${UseInlineCaches} --UseLoopPredicate=${UseLoopPredicate} --UseStringDeduplication=${UseStringDeduplication} --UseSuperWord=${UseSuperWord} --UseTypeSpeculation=${UseTypeSpeculation}

sleep 30

## Run the baseline
./scripts/perf/run-tfb-qrh-openshift.sh -s ${BENCHMARK_SERVER} -e ${RESULTS_DIR} -r -d ${DURATION} -w ${WARMUPS} -m ${MEASURES} -i ${SERVER_INSTANCES} --iter=${ITERATIONS} -n ${NAMESPACE} -t ${THREADS} -R ${RATE} --connection=${CONNECTION} --cpureq=4 --memreq=4096M --cpulim=4 --memlim=4096M

sleep 30

./scripts/perf/run-tfb-qrh-openshift.sh -s ${BENCHMARK_SERVER} -e ${RESULTS_DIR} -r -d ${DURATION} -w ${WARMUPS} -m ${MEASURES} -i ${SERVER_INSTANCES} --iter=${ITERATIONS} -n ${NAMESPACE} -t ${THREADS} -R ${RATE} --connection=${CONNECTION} --cpureq=3.88 --memreq=3016M --cpulim=3.88 --memlim=3016M --quarkustpcorethreads=25 --quarkustpqueuesize=2550 --quarkusdatasourcejdbcminsize=4 --quarkusdatasourcejdbcmaxsize=53 --FreqInlineSize=479 --MaxInlineLevel=29 --MinInliningThreshold=24 --CompileThreshold=1850 --CompileThresholdScaling=3.3 --ConcGCThreads=7 --InlineSmallCode=3376 --LoopUnrollLimit=140 --LoopUnrollMin=6 --MinSurvivorRatio=42 --NewRatio=10 --TieredStopAtLevel=4 --TieredCompilation=true --AllowParallelDefineClass=true --AllowVectorizeOnDemand=false --AlwaysCompileLoopMethods=true --AlwaysPreTouch=true --AlwaysTenure=false --BackgroundCompilation=true --DoEscapeAnalysis=true --UseInlineCaches=false --UseLoopPredicate=true --UseStringDeduplication=false --UseSuperWord=false --UseTypeSpeculation=false
