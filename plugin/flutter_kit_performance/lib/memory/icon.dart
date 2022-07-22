import 'dart:convert';

final iconBytes = base64Decode(iconData.split(",")[1]);
const iconData =
    r'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAAAXNSR0IArs4c6QAABQpJREFUeF7tnLFrFUEQh79UWlpaqAloE1Cw1EptbESFgK0igr2tjfoXpBNsLNTKFBGtrNRKbAUhhRASrNKnVlZjeAnv3c69293s3P5e+/ZmZ37zvdmdvXu3gD5NK7DQdPQKHgHQOAQCQAA0rkDj4asCCIDGFWg8fFUAAdC4Ao2HrwogABpXoPHwVQEEQOMKNB6+KoAAaFyBxsNXBRAAjSvQePiqAAKgcQUaD18VQAA0rkDj4asCCIDGFWg8fFUAAdC4Ao2HrwogAHopcAo4DRzrdZUGl1JgF9gCdqwTWivAGeA5cMNqWOOOVIE1YBX4GvPCAsBZ4GfMkL6vUoFlYKPLMwsA74GbVYYnp2IKrAMrQwHYBJZiM+n7KhXYBhaHAvC7ytDklFWBzipvWQIEgFXqOscJgDrzUswrAVBM6jonEgB15qWYV0UAuAZ8LhaSJgoKXAU+GaQQAAaRPA4RAB6zltBnAZBQTI+mBIDHrCX0WQAkFNOjKXcABIefGJQOHUWfz1PgiuGCvnYtO+wvQJi/z8di95mhq3IJgCV4y/H0pOAhATGwQos6DwBB5K5PSFRfACxH65a2WgDsZUYAdENazTlAEmKnxCoABICWgA4GVAH2NlTaA0yhxLLhqmrToiVgX4EkS6oAmF07Q8eiLgBQBZgNidrAPW2K9a1aArQEHGZAbaDaQLWBagO7fwU6Cp6hj7oAdQHRG1nqAtQFRCFRFxCVaH9AVT8oLQFaAqLoVkWszgF0DqBzgH8K6F6AHgjx9ceQJMRqCdASoCXA6RIQ3W1qQC8FklTUkm1gr+g0OKqAAIhKNO4BAmDc+Y1GJwCiEo17QHUAHJY7vFzy17hzUCy6i8CJKbMN/qdVqk3gLCXCq0rDK2bfFJNqXBPdBx4D5waEVeR/ATH/XgN3Y4P0/QEFPgLXE2hSBQAhjnvAqwQBtWDiIfAiUaDVAPASeJAoqLGbeQvcSRRkNQDM81xeIg3cmbHcgrcGVQ0AqgDWlMEoK4D2AHYARrcHUBdgT/7/kaPoAnQO0D/xk1e4OQeY9t97nQQOS/7k1dWfBFoeC08nhywFBaq7F6CXRZcF0y0AsZculJWxvtmsPySXAKQ84Kgvdek8stykcweA1eF0Mvq1ZNlTWfUschKY0mG/aUvneUo9BUC6vBSzJACKSV3nRAKgzrwU80oAFJO6zokEQJ15KeaVACgmdZ0TuQMgpYyz2pYhr2619syTccxKwtD3EpY+DCvSBgqAgwp0Pf4mACK0qAKk/DmBKkCPW6daAqbAV0vJ0h5gvsowuAJsAkvzzd37qm/ApRlXjQWAknpuA4tdWbDcdnwH3O6dyvkuCDvs8A7+aZ+xAFBSz3VgZSgAF4Dv8+Wz11U/gPMdV4wFgFJ6BimXgY2hAITrLwOPEv5d6bBPH4BbEVzGAkAJPdeAVSA8ld35sSwBkwZO7u0HjscMG7/fBbaAHcN466Nk0x6psl572I0htiyPdh2lnn9j7QuAIU8a4kkBAeApWxl8FQAZRPVkUgB4ylYGXwVABlE9mRQAnrKVwVcBkEFUTyYFgKdsZfBVAGQQ1ZNJAeApWxl8FQAZRPVkUgB4ylYGXwVABlE9mRQAnrKVwVcBkEFUTyYFgKdsZfBVAGQQ1ZNJAeApWxl8FQAZRPVkUgB4ylYGXwVABlE9mRQAnrKVwVcBkEFUTyYFgKdsZfBVAGQQ1ZNJAeApWxl8/QMuicKQqubuPgAAAABJRU5ErkJggg==';
