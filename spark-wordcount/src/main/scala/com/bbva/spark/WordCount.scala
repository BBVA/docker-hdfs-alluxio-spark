package com.bbva.spark

import alluxio.AlluxioURI
import alluxio.client.file.FileSystem
import alluxio.client.file.options.DeleteOptions
import org.apache.spark.{SparkConf, SparkContext}

object WordCount extends App {

  ConfParser.parseAndRun(args) { conf =>

    val sparkConf = new SparkConf()
      .setAppName("WordCount")
      .set("spark.logConf", "true")
      .set("spark.driver.port", "51000")
      .set("spark.fileserver.port", "51100")
      .set("spark.broadcast.port", "51200")
      .set("spark.blockManager.port", "51400")
      .set("spark.executor.port", "51500")
     // .set("alluxio.user.file.write.location.policy.class", "alluxio.client.file.policy.RoundRobinPolicy")
     // .set("alluxio.user.block.size.bytes.default", "32MB")

    val sc = SparkContext.getOrCreate(sparkConf)

    //sc.hadoopConfiguration.set("dfs.client.use.datanode.hostname", "true")
    //sc.hadoopConfiguration.set("dfs.blocksize", "33554432")

    import scala.collection.JavaConversions._
    println("dfs.client.use.datanode.hostname=" + sc.hadoopConfiguration.get("dfs.client.use.datanode.hostname"))

    sc.hadoopConfiguration.set("alluxio.user.file.writetype.default", "CACHE_THROUGH")
    sc.hadoopConfiguration.set("alluxio.user.block.size.bytes.default", "32MB")

    // Remove previous file if exists
     val fs = FileSystem.Factory.get()
     val path = new AlluxioURI(conf.outputFile)
     if (fs.exists(path)) fs.delete(path, DeleteOptions.defaults().setRecursive(true))


     val lines = sc.textFile(conf.inputFile)

    val words = lines.flatMap(_.split(" ")).cache()

    val counts = words.map(word => (word, 1)).reduceByKey(_ + _)

    println(s"Total: ${words.count()}")

    println(s"Total distinct: ${counts.count()}")

    words.saveAsTextFile(conf.outputFile)

   // sc.parallelize(1 to 10000000).map(id => "line" + id).saveAsTextFile(conf.outputFile)

    sc.stop()

  }
}
