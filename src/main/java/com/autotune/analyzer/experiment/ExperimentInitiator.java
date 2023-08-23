/*******************************************************************************
 * Copyright (c) 2022 Red Hat, IBM Corporation and others.
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
package com.autotune.analyzer.experiment;

import com.autotune.analyzer.kruizeObject.KruizeObject;
import com.autotune.analyzer.performanceProfiles.PerformanceProfileInterface.PerfProfileInterface;
import com.autotune.analyzer.serviceObjects.Converters;
import com.autotune.analyzer.serviceObjects.UpdateResultsAPIObject;
import com.autotune.analyzer.utils.AnalyzerConstants;
import com.autotune.analyzer.utils.AnalyzerErrorConstants;
import com.autotune.common.data.ValidationOutputData;
import com.autotune.common.data.result.ExperimentResultData;
import com.autotune.database.service.ExperimentDBService;
import com.google.gson.annotations.SerializedName;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.hibernate.validator.HibernateValidator;
import org.hibernate.validator.messageinterpolation.ParameterMessageInterpolator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.http.HttpServletResponse;
import java.lang.reflect.Field;
import java.sql.Timestamp;
import java.util.*;

/**
 * Initiates new experiment data validations and push into queue for worker to
 * execute task.
 */
public class ExperimentInitiator {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LoggerFactory.getLogger(ExperimentInitiator.class);
    List<UpdateResultsAPIObject> successUpdateResultsAPIObjects = new ArrayList<>();
    List<UpdateResultsAPIObject> failedUpdateResultsAPIObjects = new ArrayList<>();
    private ValidationOutputData validationOutputData;

    public static HashMap<Integer, String> getErrorMap(List<String> errorMessages) {
        HashMap<Integer, String> errorMap;
        if (null != errorMessages) {
            errorMap = new HashMap<>();
            errorMessages.forEach(
                    (errorText) -> {
                        if (AnalyzerErrorConstants.APIErrors.updateResultsAPI.ERROR_CODE_MAP.containsKey(errorText)) {
                            errorMap.put(
                                    AnalyzerErrorConstants.APIErrors.updateResultsAPI.ERROR_CODE_MAP.get(errorText),
                                    errorText
                            );
                        } else {
                            errorMap.put(HttpServletResponse.SC_BAD_REQUEST, errorText);
                        }
                    }
            );
        } else {
            errorMap = null;
        }
        return errorMap;
    }

    /**
     * Initiate Experiment validation
     *
     * @param mainKruizeExperimentMap
     * @param kruizeExpList
     */
    public void validateAndAddNewExperiments(
            Map<String, KruizeObject> mainKruizeExperimentMap,
            List<KruizeObject> kruizeExpList
    ) {
        ValidationOutputData validationOutputData = new ValidationOutputData(false, null, null);
        try {
            ExperimentValidation validationObject = new ExperimentValidation(mainKruizeExperimentMap);
            validationObject.validate(kruizeExpList);
            if (validationObject.isSuccess()) {
                ExperimentInterface experimentInterface = new ExperimentInterfaceImpl();
                experimentInterface.addExperimentToLocalStorage(mainKruizeExperimentMap, kruizeExpList);
                validationOutputData.setSuccess(true);
            } else {
                validationOutputData.setSuccess(false);
                validationOutputData.setMessage("Validation failed: " + validationObject.getErrorMessage());
            }
        } catch (Exception e) {
            LOGGER.error("Validate and push experiment falied: " + e.getMessage());
            validationOutputData.setSuccess(false);
            validationOutputData.setMessage("Validation failed: " + e.getMessage());
        }
    }

    // Generate recommendations and add it to the kruize object
    public void generateAndAddRecommendations(KruizeObject kruizeObject, List<ExperimentResultData> experimentResultDataList, Timestamp interval_start_time, Timestamp interval_end_time) throws Exception {
        if (AnalyzerConstants.PerformanceProfileConstants.perfProfileInstances.containsKey(kruizeObject.getPerformanceProfile())) {
            PerfProfileInterface perfProfileInstance =
                    (PerfProfileInterface) AnalyzerConstants.PerformanceProfileConstants
                            .perfProfileInstances.get(kruizeObject.getPerformanceProfile())
                            .getDeclaredConstructor().newInstance();
            perfProfileInstance.generateRecommendation(kruizeObject, experimentResultDataList, interval_start_time, interval_end_time);
        } else {
            throw new Exception("No Recommendation Engine mapping found for performance profile: " +
                    kruizeObject.getPerformanceProfile() + ". Cannot process recommendations for the experiment");
        }
    }

    public void validateAndAddExperimentResults(List<UpdateResultsAPIObject> updateResultsAPIObjects) {
        List<UpdateResultsAPIObject> failedDBObjects = new ArrayList<>();
        Validator validator = Validation.byProvider(HibernateValidator.class)
                .configure()
                .messageInterpolator(new ParameterMessageInterpolator())
                .failFast(false)
                .buildValidatorFactory()
                .getValidator();

        for (UpdateResultsAPIObject object : updateResultsAPIObjects) {
            Set<ConstraintViolation<UpdateResultsAPIObject>> violations = validator.validate(object, UpdateResultsAPIObject.FullValidationSequence.class);
            if (violations.isEmpty()) {
                successUpdateResultsAPIObjects.add(object);
            } else {
                List<String> errorReasons = new ArrayList<>();
                for (ConstraintViolation<UpdateResultsAPIObject> violation : violations) {
                    String propertyPath = violation.getPropertyPath().toString();
                    if (null != propertyPath && propertyPath.length() != 0) {
                        errorReasons.add(getSerializedName(propertyPath, UpdateResultsAPIObject.class) + ": " + violation.getMessage());
                    } else {
                        errorReasons.add(violation.getMessage());
                    }
                }
                object.setErrors(getErrorMap(errorReasons));
                failedUpdateResultsAPIObjects.add(object);
            }
        }
        List<ExperimentResultData> resultDataList = new ArrayList<>();
        successUpdateResultsAPIObjects.forEach(
                (successObj) -> {
                    resultDataList.add(Converters.KruizeObjectConverters.convertUpdateResultsAPIObjToExperimentResultData(successObj));
                }
        );

        if (successUpdateResultsAPIObjects.size() > 0) {
            failedDBObjects = new ExperimentDBService().addResultsToDB(resultDataList);
            failedUpdateResultsAPIObjects.addAll(failedDBObjects);
        }
    }

    public String getSerializedName(String fieldName, Class<?> targetClass) {
        Class<?> currentClass = targetClass;
        while (currentClass != null) {
            try {
                Field field = currentClass.getDeclaredField(fieldName);
                SerializedName annotation = field.getAnnotation(SerializedName.class);
                if (annotation != null) {
                    fieldName = annotation.value();
                }
            } catch (NoSuchFieldException e) {
                // Field not found in the current class
                // Move up to the superclass
                currentClass = currentClass.getSuperclass();
            }
        }
        return fieldName;
    }

    public List<UpdateResultsAPIObject> getSuccessUpdateResultsAPIObjects() {
        return successUpdateResultsAPIObjects;
    }

    public List<UpdateResultsAPIObject> getFailedUpdateResultsAPIObjects() {
        return failedUpdateResultsAPIObjects;
    }


}
