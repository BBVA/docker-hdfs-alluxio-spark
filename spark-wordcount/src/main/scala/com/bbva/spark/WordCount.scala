package com.bbva.spark

import org.apache.spark.{SparkConf, SparkContext}

object WordCount extends App {

  ConfParser.parseAndRun(args) { conf =>

    val sparkConf = new SparkConf()
      .setAppName("WordCount")
      .set("spark.logConf", "true")

    val sc = SparkContext.getOrCreate(sparkConf)

    val lines = sc.textFile(conf.inputFile)

    val words = lines.flatMap(_.split(" ")).cache()

    val counts = words.map(word => (word, 1)).reduceByKey(_ + _)

    println(s"Total: ${words.count()}")

    println(s"Total distinct: ${counts.count()}")

    words.saveAsTextFile(conf.outputFile)

  }
}
