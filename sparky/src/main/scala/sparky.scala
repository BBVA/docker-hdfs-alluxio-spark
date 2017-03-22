import org.apache.spark.SparkContext
import org.apache.spark.SparkConf
import org.rogach.scallop._

class Conf(arguments: Seq[String]) extends ScallopConf(arguments) {
  val spark = opt[String](required = true)
  val alluxio = opt[String](required = true)
  verify()
}

object sparky {
  def main(args: Array[String]) {
    val conf = new Conf(args)

    val sparkConf = new SparkConf().setAppName("Simple Application")
      .setMaster(conf.spark())
      .set("spark.driver.port", "51000")
      .set("spark.fileserver.port", "51100")
      .set("spark.broadcast.port", "51200")
      .set("spark.replClassServer.port", "51300")
      .set("spark.blockManager.port", "51400")
      .set("spark.executor.port", "51500")
      .set("spark.ui.port","51600")
    val sc = new SparkContext(sparkConf)

    val alluxioFile = sc.textFile(conf.alluxio())

    val n = alluxioFile.count()
    println("%s:%s".format(conf.alluxio(),n))
  }
}
