package com.bbva.spark

import org.apache.spark.{SparkConf, SparkContext}

object WordCount extends App {

  ConfParser.parseAndRun(args) { conf =>

    val sparkConf = new SparkConf()
      .setAppName("WordCount")
      .set("spark.logConf", "true")

    val sc = SparkContext.getOrCreate(sparkConf)

    sc.hadoopConfiguration.set("fs.defaultFS", "hdfs://hdfs-namenode:8020")

    sc.parallelize(Seq("")).repartition(7).foreachPartition(x => {
      import org.apache.log4j.{LogManager, Level}
      import org.apache.commons.logging.LogFactory

      LogManager.getRootLogger().setLevel(Level.DEBUG)
      val log = LogFactory.getLog("EXECUTOR-LOG:")
      log.debug("START EXECUTOR DEBUG LOG LEVEL")
    })

    val lines = sc.textFile(conf.inputFile)

    val words = lines.flatMap(_.split(" "))

    val counts = words.map(word => (word, 1)).reduceByKey(_ + _)

   // println(s"Total: ${words.count()}")

    println(s"Total distinct: ${counts.count()}")

    words.saveAsTextFile(conf.outputFile)

  }
}
