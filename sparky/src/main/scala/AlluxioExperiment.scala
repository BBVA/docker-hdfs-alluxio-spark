import org.apache.spark.{SparkConf, SparkContext}

object AlluxioExperiment {
  def main(args: Array[String]) {
    val conf = new Conf(args)

    val sparkConf = new SparkConf().setAppName("alluxio-experiment")
      .setMaster(conf.spark())
      .set("spark.driver.port", "51000")
      .set("spark.fileserver.port", "51100")
      .set("spark.broadcast.port", "51200")
      .set("spark.replClassServer.port", "51300")
      .set("spark.blockManager.port", "51400")
      .set("spark.executor.port", "51500")
      .set("spark.ui.port", "51600")
      .set("spark.eventLog.enabled", "true")

    val sc = new SparkContext(sparkConf)

    val alluxioFile = sc.textFile(conf.alluxio())
    alluxioFile.saveAsTextFile(conf.out())

  }
}
