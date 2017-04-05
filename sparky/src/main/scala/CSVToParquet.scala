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

    val csvFile = sc.textFile(conf.input()).map(line => Row(line.split(",").toList))

    val schema = StructType(Array(
      StructField("ID", StringType, true),
      StructField("Case_Number", StringType, true),
      StructField("Date", DateType, true),
      StructField("Block", StringType, true),
      StructField("IUCR", StringType, true),
      StructField("Primary_Type", StringType, true),
      StructField("Description", StringType, true),
      StructField("Location_Description", StringType, true),
      StructField("Arrest", BooleanType, true),
      StructField("Domestic", BooleanType, true),
      StructField("Beat", StringType, true),
      StructField("District_Ward", StringType, true),
      StructField("Community_Area", StringType, true),
      StructField("FBI_Code", StringType, true),
      StructField("X_Coordinate", StringType, true),
      StructField("Y_Coordinate", StringType, true),
      StructField("Year", StringType, true),
      StructField("Updated_On", DateType, true),
      StructField("Latitude", LongType, true),
      StructField("Longitude", LongType, true),
      StructField("Location", StringType, true)
    ))

    val dataframe = sqlContext.createDataFrame(csvFile, schema)
    dataframe.write.parquet(conf.output())
  }
}
