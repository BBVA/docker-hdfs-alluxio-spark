import org.apache.spark.SparkContext
import org.apache.spark.SparkConf

/**
  * Created by gdiazlo on 3/10/17.
  */
object sparky {

  def main(args: Array[String]) {
    val logFile = "alluxio://172.18.0.5:19998/LICENSE" // Should be some file on your system
    val conf = new SparkConf().setAppName("Simple Application")
      .setMaster("spark://172.18.0.8:7077")
      .set("spark.driver.port", "51000")
      .set("spark.fileserver.port", "51001")
      .set("spark.broadcast.port", "51002")
      .set("spark.replClassServer.port", "51003")
      .set("spark.blockManager.port", "51004")
      .set("spark.executor.port", "51005")
      .set("spark.ui.port","51080")

    val sc = new SparkContext(conf)
    val logData = sc.textFile(logFile)
    val n = logData.count()
    println("Count liness %s".format(n))
  }
}
