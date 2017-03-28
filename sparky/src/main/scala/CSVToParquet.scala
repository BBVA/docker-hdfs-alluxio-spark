import org.apache.spark.sql.{Row, SparkSession}
import org.apache.spark.sql.types._
import org.apache.spark.{SparkConf, SparkContext}

object CSVToParquet {
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
    val sqlContext = SparkSession.builder().config(sparkConf).getOrCreate()

    val csvFile = sc.textFile(conf.input()).map(line => Row(line.split(",")))

    val schema = StructType(Array(
      StructField("created_utc", DateType, false),
      StructField("score", IntegerType, false),
      StructField("domain", StringType, false),
      StructField("id", StringType, false),
      StructField("title", StringType, false),
      StructField("ups", IntegerType, false),
      StructField("downs", IntegerType, false),
      StructField("num_comments", IntegerType, false),
      StructField("permalink", StringType, false),
      StructField("selftext", StringType, false),
      StructField("link_flair_text", StringType, false),
      StructField("over_18", BooleanType, false),
      StructField("thumbnail", StringType, false),
      StructField("subreddit_id", StringType, false),
      StructField("edited", BooleanType, false),
      StructField("link_flair_css_class", StringType, false),
      StructField("author_flair_css_class", StringType, false),
      StructField("is_self", BooleanType, false),
      StructField("name", StringType, false),
      StructField("url", StringType, false),
      StructField("distinguished", StringType, false)
    ))

    val dataframe = sqlContext.createDataFrame(csvFile, schema)

    dataframe.write.parquet(conf.output())


  }
}
