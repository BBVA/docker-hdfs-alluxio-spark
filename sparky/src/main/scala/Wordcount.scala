import org.apache.spark.{SparkConf, SparkContext}

object Wordcount {
  def main(args: Array[String]) {
    val conf = new Conf(args)

    val sparkConf = new SparkConf().setAppName("WordCount")
      .setMaster(conf.spark())
      .set("spark.driver.port", "51000")
      .set("spark.fileserver.port", "51100")
      .set("spark.broadcast.port", "51200")
      .set("spark.replClassServer.port", "51300")
      .set("spark.blockManager.port", "51400")
      .set("spark.executor.port", "51500")
      .set("spark.ui.port", "51600")
    val sc = new SparkContext(sparkConf)

    val alluxioFile = sc.textFile(conf.input())

    val counts = alluxioFile.flatMap(line => line.split(" "))
      .map(word => (word, 1))
      .reduceByKey(_ + _)

    println("%s:%s".format(conf.input(), counts))

    counts.saveAsTextFile(conf.output())
  }
}
