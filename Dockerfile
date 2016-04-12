FROM dpb587/aws-cloudformation-stack-resource:master
RUN mkdir /opt/resource/stack && mv /opt/resource/check /opt/resource/common.sh /opt/resource/in /opt/resource/out /opt/resource/stack/
ADD bin /opt/resource
