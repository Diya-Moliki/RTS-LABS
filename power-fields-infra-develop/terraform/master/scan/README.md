## Building the Lambda zip file

1. Download the Python code for the antivirus, v2.0.0 for Python 3.7
https://github.com/upsidetravel/bucket-antivirus-function/releases/tag/v2.0.0
1. The function fails without resolving this [open issue](https://github.com/upsidetravel/bucket-antivirus-function/issues/125)

Extra libraries need to be added for the function to run. In the Dockerfile, change the `# Download libraries we need to run in lambda` section [23:29] to the following:

```
WORKDIR /tmp
RUN yumdownloader -x \*i686 --archlist=x86_64 clamav clamav-lib clamav-update json-c pcre2 libprelude gnutls libtasn1 lib64nettle nettle
RUN rpm2cpio clamav-0*.rpm | cpio -idmv
RUN rpm2cpio clamav-lib*.rpm | cpio -idmv
RUN rpm2cpio clamav-update*.rpm | cpio -idmv
RUN rpm2cpio json-c*.rpm | cpio -idmv
RUN rpm2cpio pcre*.rpm | cpio -idmv
RUN rpm2cpio gnutls* | cpio -idmv
RUN rpm2cpio nettle* | cpio -idmv
RUN rpm2cpio lib* | cpio -idmv
RUN rpm2cpio *.rpm | cpio -idmv
RUN rpm2cpio libtasn1* | cpio -idmv
```

3. Run `make archive` and the resulting archive will be built at `build/lambda.zip`
4. Match the archive name to the one specified in the [Terraform code](https://github.com/rtslabs/power-fields-infra/blob/ea0fb988b920fa52d0c1dba6f2d6176d44b127c8/terraform/master/scan/lambda.tf#L14), or the other way around.

---