package com.bbva.spark

import org.apache.spark.{SparkConf, SparkContext}

object WordCount extends App {

  ConfParser.parse(args, Conf()) match {
    case Some(conf) => doStaff(conf)
    case None => // ignore
  }

  def doStaff(conf: Conf): Unit = {

    val sparkConf = new SparkConf()
    sparkConf.setAppName("WordCount")

    val sc = SparkContext.getOrCreate(sparkConf)

    val lines = sc.textFile(conf.inputFile)

    val words = lines.flatMap(_.split(" "))

    val counts = words.map(word => (word, 1)).reduceByKey(_ + _)

    println(counts.take(20))

    sc.stop()

  }
}
