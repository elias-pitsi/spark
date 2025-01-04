FROM python:3.12-slim as spark-base 

ARG SPARK_VERSION=3.5.0 

RUN apt-get update && \
     apt-get install -y openjdk-11-jre-headless && \
     wget && \ 
     build-essentials && \
     ssh  && \
     apt-get clean && \
        rm -rf /var/lib/apt/lists/*

ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}
ENV SPARK_VERSION=${SPARK_VERSION}

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

RUN wget https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    tar -xvzf spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    ln -s spark-${SPARK_VERSION}-bin-hadoop3.2 latest

FROM spark-base as pyspark 

COPY requirements/requirements.txt .
RUN pip3 install -r requirements.txt

ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_HOME="/opt/spark"
ENV SPARK_MASTER="spark://spark-master:7077"
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

COPY conf/spark-defaults.conf "$SPARK_HOME/conf"

RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*

ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
