/*******************************************************************************
 * Copyright (c) 2026 IBM Corporation and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/

package com.autotune.analyzer.recommendations.layers;

import com.autotune.analyzer.kruizeLayer.impl.TunableSpec;
import com.autotune.analyzer.recommendations.LayerRecommendationHandler;
import com.autotune.analyzer.recommendations.RecommendationConstants;
import com.autotune.analyzer.recommendations.utils.RecommendationUtils;
import com.autotune.analyzer.utils.AnalyzerConstants;
import com.autotune.common.data.result.IntervalResults;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Timestamp;
import java.util.Map;

/**
 * Recommendation handler for the generic JVM layer (vendor unknown).
 * Produces only the MaxRAMPercentage recommendation; GC policy is vendor specific
 * and therefore never generated.
 */
public class JvmLayerRecommendationHandler implements LayerRecommendationHandler {
    private static final Logger LOGGER = LoggerFactory.getLogger(JvmLayerRecommendationHandler.class);

    private static final JvmLayerRecommendationHandler INSTANCE = new JvmLayerRecommendationHandler();

    public static JvmLayerRecommendationHandler getInstance() {
        return INSTANCE;
    }

    private JvmLayerRecommendationHandler() {
    }

    @Override
    public String getLayerName() {
        return AnalyzerConstants.AutotuneConfigConstants.LAYER_JVM;
    }

    @Override
    public Object generateRecommendations(String tunableName, Map<TunableSpec, Object> tunableSpecObjectMap, Map<Timestamp, IntervalResults> filteredResultsMap) {
        if (RecommendationConstants.RecommendationEngine.TunablesConstants.MAX_RAM_PERC.equals(tunableName)) {
            // Same flag and calculation for Hotspot and Semeru
            return HotspotLayerRecommendationHandler.getInstance()
                    .generateHotspotMaxRAMPercentageRecommendation(tunableName, tunableSpecObjectMap, filteredResultsMap);
        }
        LOGGER.warn("Unsupported tunable for JVM layer: {}", tunableName);
        return null;
    }

    @Override
    public void formatForEnv(String tunableName, Object value, Map<String, StringBuilder> envBuilders) {
        RecommendationUtils.formatForJVMEnv(tunableName, value, envBuilders);
    }
}

