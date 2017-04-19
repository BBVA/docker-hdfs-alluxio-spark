package com.bbva.spark

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

    val sc = SparkContext.getOrCreate(sparkConf)

    sc.hadoopConfiguration.set("dfs.client.use.datanode.hostname", "true")

    val lines = sc.textFile(conf.inputFile)

    val words = lines.flatMap(_.split(" ")).cache()

    val counts = words.map(word => (word, 1)).reduceByKey(_ + _)

    println(s"Total: ${words.count()}")

    println(s"Total distinct: ${counts.count()}")
   // counts.take(20).foreach(println)

    sc.stop()

  }
}
