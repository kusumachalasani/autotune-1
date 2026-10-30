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
package com.autotune.analyzer.kruizeLayer.impl.runtime;

import com.autotune.analyzer.kruizeLayer.impl.Layer;
import com.autotune.analyzer.kruizeLayer.impl.TunableSpec;
import com.autotune.analyzer.recommendations.RecommendationConstants;
import com.autotune.analyzer.utils.AnalyzerConstants;

import java.util.List;
import java.util.Map;

/**
 * Generic JVM layer, used when the JVM vendor (Hotspot / Semeru) is not known.
 * Only the MaxRAMPercentage tunable is supported; GC policy is vendor specific.
 */
public class JvmLayer implements Layer {
    private static final JvmLayer INSTANCE = new JvmLayer();

    private JvmLayer() {
    }

    public static JvmLayer getInstance() {
        return INSTANCE;
    }

    @Override
    public String getName() {
        return AnalyzerConstants.LayerConstants.JVM_LAYER;
    }

    @Override
    public Map<String, List<TunableSpec>> getTunableDependencies() {
        return Map.of(
                RecommendationConstants.RecommendationEngine.TunablesConstants.MAX_RAM_PERC,
                List.of(
                        new TunableSpec(
                                AnalyzerConstants.LayerConstants.CONTAINER_LAYER, RecommendationConstants.RecommendationEngine.TunablesConstants.MEMORY_LIMIT
                        )
                )
        );
    }
}
