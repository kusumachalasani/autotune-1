package com.autotune.database.dao;

import com.autotune.analyzer.kruizeObject.KruizeObject;
import com.autotune.analyzer.utils.AnalyzerConstants;
import com.autotune.common.data.ValidationOutputData;
import com.autotune.database.helper.DBConstants;
import com.autotune.database.init.KruizeHibernateUtil;
import com.autotune.database.table.KruizeExperimentEntry;
import com.autotune.database.table.KruizeRecommendationEntry;
import com.autotune.database.table.KruizeResultsEntry;
import com.autotune.utils.MetricsConfig;
import io.micrometer.core.instrument.Timer;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

import static com.autotune.database.helper.DBConstants.SQLQUERY.*;

public class ExperimentDAOImpl implements ExperimentDAO {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LoggerFactory.getLogger(ExperimentDAOImpl.class);

    @Override
    public ValidationOutputData addExperimentToDB(KruizeExperimentEntry kruizeExperimentEntry) {
        ValidationOutputData validationOutputData = new ValidationOutputData(false, null, null);
        Transaction tx = null;
        String statusValue = "failure";
        Timer.Sample timerAddExpDB = Timer.start(MetricsConfig.meterRegistry());
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()) {
            try {
                tx = session.beginTransaction();
                session.persist(kruizeExperimentEntry);
                tx.commit();
                validationOutputData.setSuccess(true);
                statusValue = "success";
            } catch (HibernateException e) {
                LOGGER.error("Not able to save experiment due to {}", e.getMessage());
                if (tx != null) tx.rollback();
                e.printStackTrace();
                validationOutputData.setSuccess(false);
                validationOutputData.setMessage(e.getMessage());
                //todo save error to API_ERROR_LOG
            }
        } catch (Exception e) {
            LOGGER.error("Not able to save experiment due to {}", e.getMessage());
            validationOutputData.setMessage(e.getMessage());
        } finally {
            if (null != timerAddExpDB) {
                MetricsConfig.timerAddExpDB = MetricsConfig.timerBAddExpDB.tag("status", statusValue).register(MetricsConfig.meterRegistry());
                timerAddExpDB.stop(MetricsConfig.timerAddExpDB);
            }
        }
        return validationOutputData;
    }

    @Override
    public ValidationOutputData addResultsToDB(KruizeResultsEntry resultsEntry) {
        ValidationOutputData validationOutputData = new ValidationOutputData(false, null, null);
        Transaction tx = null;
        String statusValue = "failure";
        Timer.Sample timerAddResultsDB = Timer.start(MetricsConfig.meterRegistry());
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()) {
            try {
                tx = session.beginTransaction();
                session.persist(resultsEntry);
                tx.commit();
                validationOutputData.setSuccess(true);
                statusValue = "success";
            } catch (HibernateException e) {
                LOGGER.error("Not able to save experiment due to {}", e.getMessage());
                if (tx != null) tx.rollback();
                e.printStackTrace();
                validationOutputData.setSuccess(false);
                validationOutputData.setMessage(e.getMessage());
                //todo save error to API_ERROR_LOG
            }
        } catch (Exception e) {
            LOGGER.error("Not able to save experiment due to {}", e.getMessage());
        } finally {
            if (null != timerAddResultsDB) {
                MetricsConfig.timerAddResultsDB = MetricsConfig.timerBAddResultsDB.tag("status", statusValue).register(MetricsConfig.meterRegistry());
                timerAddResultsDB.stop(MetricsConfig.timerAddResultsDB);
            }
        }
        return validationOutputData;
    }

    @Override
    public ValidationOutputData addRecommendationToDB(KruizeRecommendationEntry recommendationEntry) {
        ValidationOutputData validationOutputData = new ValidationOutputData(false, null, null);
        Transaction tx = null;
        String statusValue = "failure";
        Timer.Sample timerAddRecDB = Timer.start(MetricsConfig.meterRegistry());
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()) {
            try {
                tx = session.beginTransaction();
                session.persist(recommendationEntry);
                tx.commit();
                validationOutputData.setSuccess(true);
                statusValue = "success";
            } catch (Exception e) {
                LOGGER.error("Not able to save recommendation due to {}", e.getMessage());
                if (tx != null) tx.rollback();
                e.printStackTrace();
                validationOutputData.setSuccess(false);
                validationOutputData.setMessage(e.getMessage());
                //todo save error to API_ERROR_LOG
            }
        } catch (Exception e) {
            LOGGER.error("Not able to save recommendation due to {}", e.getMessage());
        } finally {
            if (null != timerAddRecDB) {
                MetricsConfig.timerAddRecDB = MetricsConfig.timerBAddRecDB.tag("status", statusValue).register(MetricsConfig.meterRegistry());
                timerAddRecDB.stop(MetricsConfig.timerAddRecDB);
            }
        }
        return validationOutputData;
    }


    @Override
    public boolean updateExperimentStatus(KruizeObject kruizeObject, AnalyzerConstants.ExperimentStatus status) {
        kruizeObject.setStatus(status);
        // TODO   update into database
        return true;
    }

    /**
     * Delete an experiment with the name experimentName
     * This deletes the experiment from all three tables
     * kruize_experiments, kruize_results and kruize_recommendations
     * Delete from kruize_results and kruize_recommendations only if the delete from kruize_experiments succeeds.
     *
     * @param experimentName
     * @return
     */
    @Override
    public ValidationOutputData deleteKruizeExperimentEntryByName(String experimentName) {
        ValidationOutputData validationOutputData = new ValidationOutputData(false, null, null);
        Transaction tx = null;
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()) {
            try {
                tx = session.beginTransaction();
                Query query = session.createQuery(DELETE_FROM_EXPERIMENTS_BY_EXP_NAME, null);
                query.setParameter("experimentName", experimentName);
                int deletedCount = query.executeUpdate();
                if (deletedCount == 0) {
                    validationOutputData.setSuccess(false);
                    validationOutputData.setMessage("KruizeExperimentEntry not found with experiment name: " + experimentName);
                } else {
                    // Remove the experiment from the Results table
                    Query kruizeResultsEntryquery = session.createQuery(DELETE_FROM_RESULTS_BY_EXP_NAME, null);
                    kruizeResultsEntryquery.setParameter("experimentName", experimentName);
                    kruizeResultsEntryquery.executeUpdate();

                    // Remove the experiment from the Recommendations table
                    Query kruizeRecommendationEntryquery = session.createQuery(DELETE_FROM_RECOMMENDATIONS_BY_EXP_NAME, null);
                    kruizeRecommendationEntryquery.setParameter("experimentName", experimentName);
                    kruizeRecommendationEntryquery.executeUpdate();
                    validationOutputData.setSuccess(true);
                }
                tx.commit();
            } catch (HibernateException e) {
                LOGGER.error("Not able to delete experiment {} due to {}", experimentName, e.getMessage());
                if (tx != null) tx.rollback();
                e.printStackTrace();
                validationOutputData.setSuccess(false);
                validationOutputData.setMessage(e.getMessage());
                //todo save error to API_ERROR_LOG
            }
        } catch (Exception e) {
            LOGGER.error("Not able to delete experiment {} due to {}", experimentName, e.getMessage());
        }
        return validationOutputData;
    }

    @Override
    public List<KruizeExperimentEntry> loadAllExperiments() throws Exception {
        //todo load only experimentStatus=inprogress , playback may not require completed experiments
        List<KruizeExperimentEntry> entries = null;
        String statusValue = "failure";
        Timer.Sample timerLoadAllExp = Timer.start(MetricsConfig.meterRegistry());
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()) {
            entries = session.createQuery(DBConstants.SQLQUERY.SELECT_FROM_EXPERIMENTS, KruizeExperimentEntry.class).list();
            statusValue = "success";
        } catch (Exception e) {
            LOGGER.error("Not able to load experiment due to {}", e.getMessage());
            throw new Exception("Error while loading exsisting experiments from database due to : " + e.getMessage());
        } finally {
            if (null != timerLoadAllExp) {
                MetricsConfig.timerLoadAllExp = MetricsConfig.timerBLoadAllExp.tag("status", statusValue).register(MetricsConfig.meterRegistry());
                timerLoadAllExp.stop(MetricsConfig.timerLoadAllExp);
            }
        }
        return entries;
    }

    @Override
    public List<KruizeResultsEntry> loadAllResults() throws Exception {
        // TODO: load only experimentStatus=inProgress , playback may not require completed experiments
        List<KruizeResultsEntry> kruizeResultsEntries = null;
        String statusValue = "failure";
        Timer.Sample timerLoadAllResults = Timer.start(MetricsConfig.meterRegistry());
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()) {
            kruizeResultsEntries = session.createQuery(DBConstants.SQLQUERY.SELECT_FROM_RESULTS, KruizeResultsEntry.class).list();
            statusValue = "success";
        } catch (Exception e) {
            LOGGER.error("Not able to load results due to: {}", e.getMessage());
            throw new Exception("Error while loading results from the database due to : " + e.getMessage());
        } finally {
            if (null != timerLoadAllResults) {
                MetricsConfig.timerLoadAllResults = MetricsConfig.timerBLoadAllResults.tag("status", statusValue).register(MetricsConfig.meterRegistry());
                timerLoadAllResults.stop(MetricsConfig.timerLoadAllResults);
            }
        }
        return kruizeResultsEntries;
    }

    @Override
    public List<KruizeRecommendationEntry> loadAllRecommendations() throws Exception {
        List<KruizeRecommendationEntry> recommendationEntries = null;
        String statusValue = "success";
        Timer.Sample timerLoadAllRec = Timer.start(MetricsConfig.meterRegistry());
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()){
            recommendationEntries = session.createQuery(
                    DBConstants.SQLQUERY.SELECT_FROM_RECOMMENDATIONS,
                    KruizeRecommendationEntry.class).list();
            statusValue = "success";
        } catch (Exception e) {
            LOGGER.error("Not able to load recommendations due to {}", e.getMessage());
            throw new Exception("Error while loading existing recommendations from database due to : " + e.getMessage());
        } finally {
            if (null != timerLoadAllRec) {
                MetricsConfig.timerLoadAllRec = MetricsConfig.timerBLoadAllRec.tag("status", statusValue).register(MetricsConfig.meterRegistry());
                timerLoadAllRec.stop(MetricsConfig.timerLoadAllRec);
            }
        }
        return recommendationEntries;
    }

    @Override
    public List<KruizeExperimentEntry> loadExperimentByName(String experimentName) throws Exception {
        //todo load only experimentStatus=inprogress , playback may not require completed experiments
        List<KruizeExperimentEntry> entries = null;
        String statusValue = "failure";
        Timer.Sample timerLoadExpName = Timer.start(MetricsConfig.meterRegistry());
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()) {
            entries = session.createQuery(DBConstants.SQLQUERY.SELECT_FROM_EXPERIMENTS_BY_EXP_NAME, KruizeExperimentEntry.class)
                    .setParameter("experimentName", experimentName).list();
        } catch (Exception e) {
            LOGGER.error("Not able to load experiment {} due to {}", experimentName, e.getMessage());
            throw new Exception("Error while loading existing experiment from database due to : " + e.getMessage());
        } finally {
            if (null != timerLoadExpName) {
                MetricsConfig.timerLoadExpName = MetricsConfig.timerBLoadExpName.tag("status", statusValue).register(MetricsConfig.meterRegistry());
                timerLoadExpName.stop(MetricsConfig.timerLoadExpName);
            }
        }
        return entries;
    }

    @Override
    public List<KruizeResultsEntry> loadResultsByExperimentName(String experimentName) throws Exception {
        // TODO: load only experimentStatus=inProgress , playback may not require completed experiments
        List<KruizeResultsEntry> kruizeResultsEntries = null;
        String statusValue = "failure";
        Timer.Sample timerLoadResultsExpName = Timer.start(MetricsConfig.meterRegistry());
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()) {
            kruizeResultsEntries = session.createQuery(DBConstants.SQLQUERY.SELECT_FROM_RESULTS_BY_EXP_NAME, KruizeResultsEntry.class)
                    .setParameter("experimentName", experimentName).list();
            statusValue = "success";
        } catch (Exception e) {
            LOGGER.error("Not able to load results due to: {}", e.getMessage());
            throw new Exception("Error while loading results from the database due to : " + e.getMessage());
        } finally {
            if (null != timerLoadResultsExpName) {
                MetricsConfig.timerLoadResultsExpName = MetricsConfig.timerBLoadResultsExpName.tag("status", statusValue).register(MetricsConfig.meterRegistry());
                timerLoadResultsExpName.stop(MetricsConfig.timerLoadResultsExpName);
            }
        }
        return kruizeResultsEntries;
    }

    @Override
    public List<KruizeRecommendationEntry> loadRecommendationsByExperimentName(String experimentName) throws Exception {
        List<KruizeRecommendationEntry> recommendationEntries = null;
        String statusValue = "failure";
        Timer.Sample timerLoadRecExpName = Timer.start(MetricsConfig.meterRegistry());
        try (Session session = KruizeHibernateUtil.getSessionFactory().openSession()){
            recommendationEntries = session.createQuery(DBConstants.SQLQUERY.SELECT_FROM_RECOMMENDATIONS_BY_EXP_NAME, KruizeRecommendationEntry.class)
                    .setParameter("experimentName", experimentName).list();
            statusValue = "success";
        } catch (Exception e) {
            LOGGER.error("Not able to load recommendations due to {}", e.getMessage());
            throw new Exception("Error while loading existing recommendations from database due to : " + e.getMessage());
        } finally {
            if (null != timerLoadRecExpName) {
                MetricsConfig.timerLoadRecExpName = MetricsConfig.timerBLoadRecExpName.tag("status", statusValue).register(MetricsConfig.meterRegistry());
                timerLoadRecExpName.stop(MetricsConfig.timerLoadRecExpName);
            }
        }
        return recommendationEntries;
    }
}
