#ifndef __LED_H_
#define __LED_H_

class LED
{
public:
    LED(unsigned int pin);
    void on(void);
    void off(void);
    unsigned int _pin;

private:
};

#endif /* __LED_H_ */